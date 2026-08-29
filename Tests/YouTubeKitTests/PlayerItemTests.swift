import AVFoundation
import Testing
@testable import YouTubeKit

#if !os(watchOS)
struct PlayerItemTests {

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    @Test(
        "Player item uses HLS and plays",
        arguments: [YouTube.ExtractionMethod.local, .remote]
    )
    @MainActor
    func playerItemUsesHLSAndPlays(method: YouTube.ExtractionMethod) async throws {
        let start = Date()
        let youtube = YouTube(videoID: "Slj4-Sv-YNA", methods: [method])
        #expect(try await youtube.isLiveContent == false)
        let item = try await youtube.playerItem()
        let asset = try #require(item.asset as? AVURLAsset)
        #expect(asset.url.scheme == "youtubekit-hls")

        let player = AVPlayer(playerItem: item)
        player.play()

        while item.status == .unknown && Date().timeIntervalSince(start) < 20 {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(item.status == .readyToPlay)

        player.playImmediately(atRate: 1)
        while player.currentTime().seconds < 0.5 && Date().timeIntervalSince(start) < 20 {
            try await Task.sleep(for: .milliseconds(50))
        }

        #expect(player.currentTime().seconds > 0.5)
        #expect(item.error == nil)
        #expect(item.presentationSize == CGSize(width: 1920, height: 1080))

        let mediaTypes = item.tracks.compactMap { $0.assetTrack?.mediaType }
        #expect(mediaTypes.contains(.video))
        #expect(mediaTypes.contains(.audio))

        print("HLS player item ready and playing in \(Date().timeIntervalSince(start)) seconds")
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    @Test(
        "Livestream player item uses native HLS and plays",
        arguments: [YouTube.ExtractionMethod.local, .remote]
    )
    @MainActor
    func livestreamPlayerItemUsesNativeHLSAndPlays(method: YouTube.ExtractionMethod) async throws {
        let youtube = YouTube(videoID: "tj4knR4r1UU", methods: [method])
        #expect(try await youtube.isLiveContent == true)
        let item = try await youtube.playerItem(maxResolution: 720)
        #expect(item.preferredMaximumResolution == CGSize(width: 1280, height: 720))
        let asset = try #require(item.asset as? AVURLAsset)
        #expect(asset.url.absoluteString.contains(".m3u8"))

        let player = AVPlayer(playerItem: item)
        let start = Date()
        player.play()

        while item.status == .unknown && Date().timeIntervalSince(start) < 20 {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(item.status == .readyToPlay)

        while player.timeControlStatus != .playing && Date().timeIntervalSince(start) < 20 {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(player.timeControlStatus == .playing)
        #expect(item.error == nil)
    }

}
#endif
