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
    @available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
    public func playerItem(maxResolution: Int? = nil) async throws -> AVPlayerItem {
        // For livestreams: use the direct url
        let isLiveContent = (try? await isLiveContent) ?? false
        if isLiveContent, let livestream = try await livestreams.first {
            let playerItem = AVPlayerItem(url: livestream.url)
#if !os(watchOS)
            if let maxResolution {
                playerItem.preferredMaximumResolution = CGSize(width: CGFloat(maxResolution) * 16 / 9, height: CGFloat(maxResolution))
            }
#endif
            return playerItem
        }

        let streams = try await streams
        let nativelyPlayableStreams = streams.filter(\.isNativelyPlayable)

        let videoStream = nativelyPlayableStreams
            .filter { $0.fileExtension != .m3u8 }
            .filterVideoOnly()
            .filter(byResolution: { ($0 ?? .max) <= (maxResolution ?? .max) })
            .highestResolutionStream()
        let audioStream = nativelyPlayableStreams.filterAudioOnly().highestAudioBitrateStream()
        let bestCombinedStream = nativelyPlayableStreams
            .filterVideoAndAudio()
            .filter(byResolution: { ($0 ?? .max) <= (maxResolution ?? .max) })
            .highestResolutionStream()

        // prefer already combined streams if available
        if let bestCombinedStream {
            if videoStream == nil || (bestCombinedStream.videoResolution ?? 0) >= (videoStream?.videoResolution ?? 0) {
                os_log("Using already combined stream for %{public}@", log: OSLog(category: "YouTube+PlayerItem"), type: .info, videoID)
                return AVPlayerItem(asset: AVURLAsset(url: bestCombinedStream.url))
            }
        }

        guard let videoStream, let audioStream else {
            throw YouTubeKitError.extractError
        }

        let metadataDuration = try await metadata?.duration
        let videoDuration = metadataDuration.flatMap { $0 > 0 ? $0 : nil }

#if !os(watchOS)
        if videoStream.fileExtension == .mp4,
           audioStream.fileExtension == .m4a,
           let videoDuration {
            do {
                return try await HLSPlayerItem.make(
                    videoStream: videoStream,
                    audioStream: audioStream,
                    duration: videoDuration
                )
            } catch let error as CancellationError {
                throw error
            } catch {
                os_log("Couldn't create HLS player item for %{public}@: %{public}@. Falling back to AVMutableComposition.", log: OSLog(category: "YouTube+PlayerItem"), type: .info, videoID, error.localizedDescription)
            }
        }
#endif

        return try await compositionPlayerItem(
            videoStream: videoStream,
            audioStream: audioStream,
            duration: videoDuration
        )
    }

    @MainActor
    @available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
    private func compositionPlayerItem(videoStream: Stream, audioStream: Stream, duration: TimeInterval?) async throws -> AVPlayerItem {
        
        let composition = AVMutableComposition()

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
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            throw YouTubeKitError.compositionTrackCreationFailed
        }
        let videoTimeRange = if let duration {
            CMTime(seconds: duration, preferredTimescale: 1_000)
        } else {
            try await videoAsset.load(.duration)
        }
        try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoTimeRange), of: videoAssetTrack, at: .zero)

        // add audio track
        try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoTimeRange), of: audioAssetTrack, at: .zero)

        let playerItem = AVPlayerItem(asset: composition)
        return playerItem
    }

}
