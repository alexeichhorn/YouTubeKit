//
//  YouTube+PlayerItem.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 15.10.2024.
//

import Foundation
import AVFoundation
import os.log

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension YouTube {

    /// Returns video+audio `AVPlayerItem` for the highest resolution stream that is natively playable with potentially audio and video automatically combined.
    /// This means it will have most of the time higher resolution and bitrate than from a single `.streams.filterVideoAndAudio()` stream alone.
    /// - Parameter maxResolution: The maximum resolution of the video stream. If `nil`, the highest resolution stream is used.
    @MainActor
    @available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
    public func playerItem(maxResolution: Int? = nil) async throws -> AVPlayerItem {
        let streams = try await streams

        let composition = AVMutableComposition()

        guard let videoStream = streams.filter({ $0.isNativelyPlayable && $0.url.pathExtension != "m3u8" }).filterVideoOnly().filter(byResolution: { ($0 ?? .max) <= (maxResolution ?? .max) }).highestResolutionStream(),
              let audioStream = streams.filter({ $0.isNativelyPlayable }).filterAudioOnly().highestAudioBitrateStream() else {
            throw YouTubeKitError.extractError
        }

        // prefer already combined streams if available
        if let bestCombinedStream = streams.filter({ $0.isNativelyPlayable }).filterVideoAndAudio().filter(byResolution: { ($0 ?? .max) <= (maxResolution ?? .max) }).highestResolutionStream() {
            if (bestCombinedStream.videoResolution ?? 0) >= (videoStream.videoResolution ?? 0) {
                os_log("Using already combined stream for %{public}@", log: OSLog(category: "YouTube+PlayerItem"), type: .info, videoID)
                return AVPlayerItem(asset: AVURLAsset(url: bestCombinedStream.url))
            }
        }
        
        let videoDuration = try await metadata?.duration
        let videoDurationTime = videoDuration.map { CMTime(value: CMTimeValue($0 * 1000), timescale: 1000) }

        // prepare video track
        let videoAsset = AVURLAsset(url: videoStream.url)
        async let videoAssetTrackTask = videoAsset.loadTracks(withMediaType: .video).first

        // prepare audio track
        let audioAsset = AVURLAsset(url: audioStream.url)
        async let audioAssetTrackTask = audioAsset.loadTracks(withMediaType: .audio).first

        // await video and audio track loading concurrently
        guard let videoAssetTrack = try await videoAssetTrackTask, let audioAssetTrack = try await audioAssetTrackTask else {
            throw YouTubeKitError.extractError
        }

        // add video track
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let videoTimeRange = if let videoDurationTime {
            videoDurationTime
        } else {
            try await videoAsset.load(.duration)
        }
        try videoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoTimeRange), of: videoAssetTrack, at: .zero)

        // add audio track
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        try audioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoTimeRange), of: audioAssetTrack, at: .zero)

        let playerItem = AVPlayerItem(asset: composition)
        return playerItem
    }

}
