//
//  HLSPlayerItem.swift
//  YouTubeKit
//

import AVFoundation
import Foundation

#if !os(watchOS)
enum HLSPlayerItem {

    @available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
    static func make(videoStream: Stream, audioStream: Stream, duration: TimeInterval) async throws -> AVPlayerItem {
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

    private static func codecIdentifier(_ codec: VideoCodec?) throws -> String {
        switch codec {
        case .avc1(let version): "avc1.\(version)"
        case .av1(let version): "av01.\(version)"
        case .mp4v(let version): "mp4v.\(version)"
        case .vp9(let version): "vp09.\(version)"
        case .unknown(let codec): codec
        case nil: throw HLSPlayerItemError.unsupportedCodec
        }
    }

    private static func codecIdentifier(_ codec: AudioCodec?) throws -> String {
        switch codec {
        case .mp4a(let version): "mp4a.\(version)"
        case .ac3: "ac-3"
        case .ec3: "ec-3"
        case .opus: "opus"
        case .unknown(let codec): codec
        case nil: throw HLSPlayerItemError.unsupportedCodec
        }
    }
}

enum HLSPlayerItemError: LocalizedError {
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
#endif
