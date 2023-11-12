//
//  PlayabilityTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 12.11.23.
//

import XCTest
@testable import YouTubeKit
import AVFoundation

@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
final class PlayabilityTests: XCTestCase {
    
    private func checkStreamPlayability(stream: YouTubeKit.Stream) async throws -> Bool {
        do {
            let asset = AVAsset(url: stream.url)
            return try await asset.load(.isPlayable)
        } catch {
            return false
        }
    }
    
    func testStandardStreamNativePlayability() async {
        
        let videoID = "V3dbG9pAi8I"
        let youtubeLocal = YouTube(videoID: videoID, methods: [.local])
        let youtubeRemote = YouTube(videoID: videoID, methods: [.remote])
        
        do {
            let streams = try await youtubeLocal.streams + youtubeRemote.streams
            
            for stream in streams {
                let isPlayable = try await checkStreamPlayability(stream: stream)
                XCTAssertEqual(stream.isNativelyPlayable, isPlayable, "Stream has incorrect playability prediction: \(stream)")
            }
            
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    
    func testHDRStreamNativePlayability() async {
        
        let videoID = "njX2bu-_Vw4"
        let youtubeLocal = YouTube(videoID: videoID, methods: [.local])
        let youtubeRemote = YouTube(videoID: videoID, methods: [.remote])
        
        do {
            let streams = try await youtubeLocal.streams + youtubeRemote.streams
            
            for stream in streams {
                let isPlayable = try await checkStreamPlayability(stream: stream)
                XCTAssertEqual(stream.isNativelyPlayable, isPlayable, "Stream has incorrect playability prediction: \(stream)")
            }
            
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
}
