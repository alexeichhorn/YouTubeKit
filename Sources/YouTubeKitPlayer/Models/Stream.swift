//
//  Stream.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 06.09.21.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public struct Stream: Sendable {
    
    public let url: URL
    public let itag: ITag
    public let videoCodec: VideoCodec?
    public let audioCodec: AudioCodec?
    
    public let fileExtension: FileExtension
    
    public let bitrate: Int?
    public let averageBitrate: Int?
    
    @available(*, deprecated, message: "Might be empty if using remote fetching method. Use `videoCodec`, `audioCodec` or `fileExtension` instead.")
    public let mimeType: String
    
    @available(*, deprecated, message: "Might be empty if using remote fetching method. Use `videoCodec`, `audioCodec` or `fileExtension` instead.")
    public let type: String
        
    @available(*, deprecated, message: "Might be empty if using remote fetching method. Use `videoCodec`, `audioCodec` or `fileExtension` instead.")
    public let subtype: String
    
    private let filesize: Int?
    
    init(format: InnerTube.StreamingData.Format) throws {
        guard let url = format.url.flatMap({ URL(string: $0) }),
              let itag = ITag(format.itag) else {
            throw YouTubeKitError.extractError
        }
        
        self.url = url
        self.itag = itag
        
        let codecs: [String]
        (self.mimeType, codecs) = try Extraction.mimeTypeCodec(format.mimeType)
        
        let mimeTypeComponents = self.mimeType.components(separatedBy: "/")
        self.type = mimeTypeComponents.first ?? ""
        self.subtype = mimeTypeComponents[safe: 1] ?? ""
        
        self.fileExtension = FileExtension(mimeType: self.mimeType)
        
        // codec decoding
        if codecs.count >= 2 {
            self.videoCodec = VideoCodec(rawValue: codecs[0])
            self.audioCodec = AudioCodec(rawValue: codecs[1])
        } else if let codec = codecs.first {
            if self.type == "audio" {
                self.audioCodec = AudioCodec(rawValue: codec)
                self.videoCodec = nil
            } else {
                self.videoCodec = VideoCodec(rawValue: codec)
                self.audioCodec = nil
            }
        } else {
            throw YouTubeKitError.extractError
        }
        
        self.bitrate = format.bitrate
        self.averageBitrate = format.averageBitrate
        self.filesize = format.contentLength.flatMap { Int($0) }
    }
    
    init(remoteStream: RemoteStream) throws {
        guard let itag = ITag(remoteStream.itag) else {
            throw YouTubeKitError.extractError
        }
        
        self.url = remoteStream.url
        self.itag = itag
        self.videoCodec = remoteStream.videoCodec.map { VideoCodec(rawValue: $0) }
        self.audioCodec = remoteStream.audioCodec.map { AudioCodec(rawValue: $0) }
        
        if self.videoCodec == nil && self.audioCodec == nil {
            throw YouTubeKitError.extractError
        }
        
        self.fileExtension = FileExtension(rawValue: remoteStream.ext) ?? .unknown
        
        self.bitrate = remoteStream.videoBitrate ?? remoteStream.audioBitrate
        self.averageBitrate = remoteStream.averageBitrate
        self.filesize = remoteStream.filesize
        
        // Backward compatibility for deprecated `subtype` and `mimeType`
        self.type = (remoteStream.videoCodec != nil) ? "video" : "audio"
        self.subtype = ""
        self.mimeType = ""
    }
    
    /// whether the stream is DASH
    public var isAdaptive: Bool {
        videoCodec == nil || audioCodec == nil
    }
    
    /// video and audio in same stream
    /// opposite of adaptive (is not DASH)
    public var isProgressive: Bool {
        !isAdaptive
    }
    
    public var isDash: Bool {
        itag.isDash
    }
    
    /// Whether the stream only contains audio.
    public var includesAudioTrack: Bool {
        audioCodec != nil
    }
    
    /// Whether the stream only contains video.
    public var includesVideoTrack: Bool {
        videoCodec != nil
    }
    
    /// Whether the stream contains both audio and video tracks.
    /// - note: alias of `isProgressive`
    @inlinable public var includesVideoAndAudioTrack: Bool {
        isProgressive
    }
    
    /// Whether the stream can be played inside the native `AVPlayer`
    public var isNativelyPlayable: Bool {
        (videoCodec?.isNativelyPlayable ?? true) && (audioCodec?.isNativelyPlayable ?? true)
    }
    
    /// smaller pixel size of resolution (e.g. 1080 for 1080p)
    /// - note: is nil, if no video available
    public var videoResolution: Int? {
        itag.videoResolution
    }
    
}
