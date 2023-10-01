//
//  Stream.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 06.09.21.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public struct Stream {
    
    public let url: URL
    public let itag: ITag
    public let mimeType: String
    public let codecs: [String]
    public let type: String
    public let subtype: String
    
    public let fileExtension: FileExtension
    
    public let bitrate: Int?
    public let averageBitrate: Int?
    public let isDash: Bool
    
    private let filesize: Int?
    
    init(format: InnerTube.StreamingData.Format) throws {
        guard let url = format.url.flatMap({ URL(string: $0) }),
              let itag = ITag(format.itag) else {
            throw YouTubeKitError.extractError
        }
        
        self.url = url
        self.itag = itag
        (self.mimeType, self.codecs) = try Extraction.mimeTypeCodec(format.mimeType)
        
        let mimeTypeComponents = self.mimeType.components(separatedBy: "/")
        self.type = mimeTypeComponents.first ?? ""
        self.subtype = mimeTypeComponents[safe: 1] ?? ""
        
        self.fileExtension = FileExtension(mimeType: self.mimeType)
        
        self.bitrate = format.bitrate
        self.averageBitrate = format.averageBitrate
        self.filesize = format.contentLength.flatMap { Int($0) }
        
        self.isDash = itag.isDash
    }
    
    /// whether the stream is DASH
    public var isAdaptive: Bool {
        codecs.count % 2 == 1
    }
    
    /// video and audio in same stream
    /// opposite of adaptive (is not DASH)
    public var isProgressive: Bool {
        !isAdaptive
    }
    
    /// Whether the stream only contains audio.
    public var includesAudioTrack: Bool {
        isProgressive || type == "audio"
    }
    
    /// Whether the stream only contains video.
    public var includesVideoTrack: Bool {
        isProgressive || type == "video"
    }
    
    public lazy var videoCodec: String? = {
        if !isAdaptive || includesVideoTrack {
            return codecs.first
        }
        return nil
    }()
    
    public lazy var audioCodec: String? = {
        if !isAdaptive {
            return codecs.last
        } else if includesAudioTrack {
            return codecs.first
        }
        return nil
    }()
    
}
