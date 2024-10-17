//
//  YouTube+PlayerItem.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 15.10.2024.
//

import Foundation
import AVFoundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension YouTube {

    /// Returns `AVPlayerItem` for the highest resolution stream that is natively playable with potentially audio and video automatically combined.
    /// - Parameter maxResolution: The maximum resolution of the video stream. If `nil`, the highest resolution stream is used.
    @MainActor
    @available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
    public func playerItem(maxResolution: Int? = nil) async throws -> AVPlayerItem {
        let streams = try await streams

        let composition = AVMutableComposition()

        guard let videoStream = streams.filter({ $0.isNativelyPlayable }).filterVideoOnly().filter(byResolution: { ($0 ?? .max) <= (maxResolution ?? .max) }).highestResolutionStream(),
              let audioStream = streams.filter({ $0.isNativelyPlayable }).filterAudioOnly().highestAudioBitrateStream() else {
            throw YouTubeKitError.extractError
        }

        // Add video track
        let videoAsset = AVURLAsset(url: videoStream.url)
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let videoAssetTrack = try await videoAsset.loadTracks(withMediaType: .video).first
        let videoTimeRange = try await videoAsset.load(.duration)
        try videoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoTimeRange), of: videoAssetTrack!, at: .zero)

        // Add audio track
        let audioAsset = AVURLAsset(url: audioStream.url)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioAssetTrack = try await audioAsset.load(.tracks).first { $0.mediaType == .audio }
        let audioTimeRange = try await audioAsset.load(.duration)
        try audioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: audioTimeRange), of: audioAssetTrack!, at: .zero)

        let playerItem = AVPlayerItem(asset: composition)
        return playerItem
    }

}
