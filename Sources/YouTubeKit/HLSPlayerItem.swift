//
//  HLSPlayerItem.swift
//  YouTubeKit
//

import AVFoundation
import Foundation

@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
func makeHLSPlayerItem(videoStream: Stream, audioStream: Stream, duration: TimeInterval) async throws -> AVPlayerItem {

    async let videoIndex = MP4Index.load(from: videoStream.url)
    async let audioIndex = MP4Index.load(from: audioStream.url)
    let (loadedVideoIndex, loadedAudioIndex) = try await (videoIndex, audioIndex)

    let videoCodec = try codecIdentifier(videoStream.videoCodec)
    let audioCodec = try codecIdentifier(audioStream.audioCodec)
    let resolution = if let width = videoStream.width, let height = videoStream.height {
        ",RESOLUTION=\(width)x\(height)"
    } else {
        ""
    }
    let bandwidth = (videoStream.bitrate ?? 5_000_000) + (audioStream.bitrate ?? 128_000)
    let baseURL = "youtubekit-hls://playlist-\(UUID().uuidString.lowercased())"
    let masterPlaylist = """
    #EXTM3U
    #EXT-X-VERSION:7
    #EXT-X-INDEPENDENT-SEGMENTS
    #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="Default",DEFAULT=YES,AUTOSELECT=YES,URI="\(baseURL)/audio.m3u8"
    #EXT-X-STREAM-INF:BANDWIDTH=\(bandwidth)\(resolution),CODECS="\(videoCodec),\(audioCodec)",AUDIO="audio"
    \(baseURL)/video.m3u8

    """

    let asset = HLSURLAsset(
        url: URL(string: "\(baseURL)/master.m3u8")!,
        playlists: [
            "/master.m3u8": masterPlaylist,
            "/video.m3u8": loadedVideoIndex.playlist(url: videoStream.url),
            "/audio.m3u8": loadedAudioIndex.playlist(url: audioStream.url),
        ]
    )
    let item = AVPlayerItem(asset: asset)
    item.forwardPlaybackEndTime = CMTime(seconds: duration, preferredTimescale: 1_000)
    item.preferredForwardBufferDuration = 5
    return item
}

private func codecIdentifier(_ codec: VideoCodec?) throws -> String {
    switch codec {
    case .avc1(let version): "avc1.\(version)"
    case .av1(let version): "av01.\(version)"
    case .mp4v(let version): "mp4v.\(version)"
    case .vp9(let version): "vp09.\(version)"
    case .unknown(let codec): codec
    case nil: throw HLSPlayerItemError.unsupportedCodec
    }
}

private func codecIdentifier(_ codec: AudioCodec?) throws -> String {
    switch codec {
    case .mp4a(let version): "mp4a.\(version)"
    case .ac3: "ac-3"
    case .ec3: "ec-3"
    case .opus: "opus"
    case .unknown(let codec): codec
    case nil: throw HLSPlayerItemError.unsupportedCodec
    }
}

private enum HLSPlayerItemError: LocalizedError {
    case invalidResponse
    case malformedIndex
    case unsupportedCodec

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The media server did not return the requested MP4 index range."
        case .malformedIndex: "The MP4 stream did not contain a supported SIDX box."
        case .unsupportedCodec: "The selected stream codec cannot be represented in HLS."
        }
    }
}

private final class HLSURLAsset: AVURLAsset, @unchecked Sendable {
    private let playlistLoader: HLSPlaylistResourceLoader

    init(url: URL, playlists: [String: String]) {
        let playlistLoader = HLSPlaylistResourceLoader(playlists: playlists)
        self.playlistLoader = playlistLoader
        super.init(url: url, options: nil)
        resourceLoader.setDelegate(
            playlistLoader,
            queue: DispatchQueue(label: "YouTubeKit.HLSPlaylistResourceLoader")
        )
    }
}

private final class HLSPlaylistResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    private let playlists: [String: Data]

    init(playlists: [String: String]) {
        self.playlists = playlists.mapValues { Data($0.utf8) }
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard let url = loadingRequest.request.url,
              let data = playlists[url.path] else {
            return false
        }

        loadingRequest.contentInformationRequest?.contentType = "public.m3u-playlist"
        loadingRequest.contentInformationRequest?.contentLength = Int64(data.count)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true

        if let dataRequest = loadingRequest.dataRequest {
            guard dataRequest.currentOffset >= 0,
                  dataRequest.currentOffset <= Int64(data.count) else {
                loadingRequest.finishLoading(with: HLSPlayerItemError.invalidResponse)
                return true
            }
            let start = Int(dataRequest.currentOffset)
            let end = start + min(dataRequest.requestedLength, data.count - start)
            if start < end {
                dataRequest.respond(with: data[start..<end])
            }
        }

        loadingRequest.finishLoading()
        return true
    }
}

@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
private struct MP4Index {
    struct Segment {
        let offset: UInt64
        let length: UInt64
        let duration: Double
    }

    let initializationLength: UInt64
    let segments: [Segment]

    static func load(from url: URL) async throws -> MP4Index {
        var request = URLRequest(url: url)
        request.setValue("bytes=0-1048575", forHTTPHeaderField: "Range")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 206 else {
            throw HLSPlayerItemError.invalidResponse
        }
        return try MP4Index(data: data)
    }

    init(data: Data) throws {
        var boxOffset = 0

        while boxOffset + 8 <= data.count {
            let size32 = UInt64(try data.uint32(at: boxOffset))
            let type = try data.ascii(at: boxOffset + 4, length: 4)
            let headerLength = size32 == 1 ? 16 : 8
            let boxSize = size32 == 1 ? try data.uint64(at: boxOffset + 8) : size32

            guard boxSize >= UInt64(headerLength),
                  boxSize <= UInt64(Int.max),
                  boxOffset <= data.count - Int(boxSize) else {
                throw HLSPlayerItemError.malformedIndex
            }

            if type == "sidx" {
                self = try MP4Index(sidx: data, offset: boxOffset, size: Int(boxSize), headerLength: headerLength)
                return
            }

            boxOffset += Int(boxSize)
        }

        throw HLSPlayerItemError.malformedIndex
    }

    private init(sidx data: Data, offset: Int, size: Int, headerLength: Int) throws {
        let boxEnd = offset + size
        var cursor = offset + headerLength
        let version = try data.byte(at: cursor)
        cursor += 4 // version and flags
        cursor += 4 // reference ID
        let timescale = try data.uint32(at: cursor)
        cursor += 4
        guard timescale > 0 else { throw HLSPlayerItemError.malformedIndex }

        let firstOffset: UInt64
        if version == 0 {
            cursor += 4 // earliest presentation time
            firstOffset = UInt64(try data.uint32(at: cursor))
            cursor += 4
        } else if version == 1 {
            cursor += 8 // earliest presentation time
            firstOffset = try data.uint64(at: cursor)
            cursor += 8
        } else {
            throw HLSPlayerItemError.malformedIndex
        }

        cursor += 2 // reserved
        let referenceCount = Int(try data.uint16(at: cursor))
        cursor += 2
        guard referenceCount > 0,
              cursor <= boxEnd,
              referenceCount <= (boxEnd - cursor) / 12 else {
            throw HLSPlayerItemError.malformedIndex
        }

        let (firstSegmentOffset, firstOffsetOverflow) = UInt64(boxEnd).addingReportingOverflow(firstOffset)
        guard !firstOffsetOverflow else { throw HLSPlayerItemError.malformedIndex }
        var segmentOffset = firstSegmentOffset
        var parsedSegments = [Segment]()
        parsedSegments.reserveCapacity(referenceCount)

        for _ in 0..<referenceCount {
            let reference = try data.uint32(at: cursor)
            cursor += 4
            guard reference >> 31 == 0 else { throw HLSPlayerItemError.malformedIndex }
            let length = UInt64(reference & 0x7fff_ffff)
            let duration = Double(try data.uint32(at: cursor)) / Double(timescale)
            cursor += 8 // duration and SAP information
            guard length > 0, duration > 0 else { throw HLSPlayerItemError.malformedIndex }
            parsedSegments.append(Segment(offset: segmentOffset, length: length, duration: duration))
            let (nextSegmentOffset, segmentOffsetOverflow) = segmentOffset.addingReportingOverflow(length)
            guard !segmentOffsetOverflow else { throw HLSPlayerItemError.malformedIndex }
            segmentOffset = nextSegmentOffset
        }

        initializationLength = UInt64(offset)
        segments = parsedSegments
    }

    func playlist(url: URL) -> String {
        let targetDuration = max(1, Int(ceil(segments.map(\.duration).max() ?? 1)))
        var lines = [
            "#EXTM3U",
            "#EXT-X-VERSION:7",
            "#EXT-X-TARGETDURATION:\(targetDuration)",
            "#EXT-X-MEDIA-SEQUENCE:0",
            "#EXT-X-PLAYLIST-TYPE:VOD",
            "#EXT-X-MAP:URI=\"\(rangedURL(url, offset: 0, length: initializationLength))\"",
        ]

        for segment in segments {
            lines.append("#EXTINF:\(String(format: "%.6f", segment.duration)),")
            lines.append(rangedURL(url, offset: segment.offset, length: segment.length))
        }
        lines.append("#EXT-X-ENDLIST")
        return lines.joined(separator: "\n") + "\n"
    }

    private func rangedURL(_ url: URL, offset: UInt64, length: UInt64) -> String {
        guard length > 0,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString
        }
        let (endOffset, offsetOverflow) = offset.addingReportingOverflow(length - 1)
        guard !offsetOverflow else { return url.absoluteString }
        var queryItems = components.queryItems ?? []
        queryItems.removeAll { $0.name == "range" }
        queryItems.append(URLQueryItem(name: "range", value: "\(offset)-\(endOffset)"))
        components.queryItems = queryItems
        return (components.url?.absoluteString ?? url.absoluteString)
            .replacingOccurrences(of: "\"", with: "%22")
    }
}

private extension Data {
    func byte(at offset: Int) throws -> UInt8 {
        guard indices.contains(offset) else { throw HLSPlayerItemError.malformedIndex }
        return self[offset]
    }

    func uint16(at offset: Int) throws -> UInt16 {
        guard offset >= 0, offset <= count - 2 else { throw HLSPlayerItemError.malformedIndex }
        return (UInt16(self[offset]) << 8) | UInt16(self[offset + 1])
    }

    func uint32(at offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= count - 4 else { throw HLSPlayerItemError.malformedIndex }
        return (UInt32(self[offset]) << 24)
            | (UInt32(self[offset + 1]) << 16)
            | (UInt32(self[offset + 2]) << 8)
            | UInt32(self[offset + 3])
    }

    func uint64(at offset: Int) throws -> UInt64 {
        (UInt64(try uint32(at: offset)) << 32) | UInt64(try uint32(at: offset + 4))
    }

    func ascii(at offset: Int, length: Int) throws -> String {
        guard offset >= 0, length >= 0, offset <= count - length else {
            throw HLSPlayerItemError.malformedIndex
        }
        return String(decoding: self[offset..<(offset + length)], as: UTF8.self)
    }
}
