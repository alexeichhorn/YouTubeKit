//
//  YouTubeMetadata.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation

public struct YouTubeMetadata {
    public let title: String
    public let description: String
    public let thumbnail: Thumbnail?

    public struct Thumbnail {
        public let url: URL
    }

    @available(iOS 13.0, *)
    static func metadata(from videoDetails: InnerTube.VideoInfo.VideoDetails) -> Self {
        YouTubeMetadata(
            title: videoDetails.title,
            description: videoDetails.shortDescription,
            thumbnail: videoDetails.thumbnail.thumbnails.map { YouTubeMetadata.Thumbnail(url: $0.url) }.last
        )
    }
}
