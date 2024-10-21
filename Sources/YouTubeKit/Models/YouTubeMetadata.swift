//
//  YouTubeMetadata.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation

/// Represents metadata for a YouTube video.
public struct YouTubeMetadata: Sendable {
    
    /// The title of the YouTube video.
    public let title: String

    /// The description of the YouTube video.
    public let description: String

    /// The thumbnail image of the YouTube video, if available.
    public let thumbnail: Thumbnail?

    /// Represents a YouTube video thumbnail.
    public struct Thumbnail: Sendable {
        /// The URL of the thumbnail image.
        public let url: URL
    }

    /// Initialize YouTubeMetadata from video details.
    ///
    /// - Parameters:
    ///   - videoDetails: The video details from InnerTube.VideoInfo.VideoDetails.
    /// - Returns: A YouTubeMetadata instance.
    @available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
    static func metadata(from videoDetails: InnerTube.VideoInfo.VideoDetails) -> Self {
        YouTubeMetadata(
            title: videoDetails.title,
            description: videoDetails.shortDescription,
            thumbnail: videoDetails.thumbnail.thumbnails.map { YouTubeMetadata.Thumbnail(url: $0.url) }.last
        )
    }
    
}
