//
//  Stream.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 06.09.21.
//

import Foundation

public struct Stream {
    
    public let url: URL
    public let itag: ITag
    public let mimeType: String
    public let codecs: [String]
    public let type: String
    public let subtype: String
    
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
        
        self.bitrate = format.bitrate
        self.averageBitrate = format.averageBitrate
        self.filesize = format.contentLength.flatMap { Int($0) }
        
        self.isDash = itag.isDash
    }
    
    /// whether the stream is DASH
    var isAdaptive: Bool {
        codecs.count % 2 == 1
    }
    
    /// opposite of adaptive (is not DASH)
    var isProgressive: Bool {
        !isAdaptive
    }
    
    /// Whether the stream only contains audio.
    var includesAudioTrack: Bool {
        isProgressive || type == "audio"
    }
    
    /// Whether the stream only contains video.
    var includesVideoTrack: Bool {
        isProgressive || type == "video"
    }
    
    lazy var videoCodec: String? = {
        if !isAdaptive || includesVideoTrack {
            return codecs.first
        }
        return nil
    }()
    
    lazy var audioCodec: String? = {
        if !isAdaptive {
            return codecs.last
        } else if includesAudioTrack {
            return codecs.first
        }
        return nil
    }()
    
}
