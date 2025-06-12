//
//  NSigTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 12.06.2025.
//

import Testing
import Foundation
@testable import YouTubeKit

struct NSigTests {
    
    struct NSigPlayerRequest {
        let playerURL: URL
        let input: String
        let output: String
    }
    
    private func downloadJavascript(fromURL url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        let js = String(data: data, encoding: .utf8)
        return try #require(js, "Failed to download JavaScript from \(url)")
    }
    
    @Test("NSig over all players", arguments: [
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/7862ca1f/player_ias.vflset/en_US/base.js")!, input: "X_LCxVDjAavgE5t", output: "yxJ1dM6iz5ogUg"),
    ])
    func nSigForPlayerURL(_ request: NSigPlayerRequest) async throws {
        let js = try await downloadJavascript(fromURL: request.playerURL)
        let cipher = try Cipher(js: js)
        let calculatedN = try cipher.calculateN(initialN: request.input)
        #expect(calculatedN == request.output)
    }
    
}

