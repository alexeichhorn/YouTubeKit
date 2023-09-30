//
//  Stream.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.08.23.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public struct Livestream {
    public enum StreamType {
        case hls
    }
    
    public let url: URL
    public let streamType: StreamType
    public var metadata: YouTubeMetadata {
        .init(
            title: videoDetails.title,
            description: videoDetails.shortDescription,
            thumbnail: videoDetails.thumbnail.thumbnails.map { YouTubeMetadata.Thumbnail(url: $0.url) }.last
        )
    }
    
    let videoDetails: InnerTube.VideoInfo.VideoDetails
}
