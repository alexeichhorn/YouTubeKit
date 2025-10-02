//
//  CipherTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 05.09.21.
//

import XCTest
@testable import YouTubeKit

@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
final class CipherTests: XCTestCase {
    
    func testGetInitialFunctionNameWithNoMatch() {
        XCTAssertThrowsError(try Cipher.getInitialFunctionName(js: "asdf")) { error in
            XCTAssertEqual(error as? YouTubeKitError, .regexMatchError)
        }
    }
    
    func testGetTransformObjectWithNoMatch() {
        XCTAssertThrowsError(try Cipher.getTransformObject(js: "asdf", variable: "lt")) { error in
            XCTAssertEqual(error as? YouTubeKitError, .regexMatchError)
        }
    }

    func testConcurrentCalculateN() async throws {
        // This test reproduces issue #98: concurrent JSContext creation crashes
        // Simulates real usage: multiple YouTube objects calling streams concurrently
        // Using test data from NSigTests
        let playerURL = URL(string: "https://www.youtube.com/s/player/fc2a56a5/player_ias.vflset/en_US/base.js")!
        let input = "qTKWg_Il804jd2kAC"
        let expectedOutput = "OtUAm2W6gyzJjB9u"
        
        let numCiphers = 100

        // Download JS once
        let (data, _) = try await URLSession.shared.data(from: playerURL)
        let js = String(data: data, encoding: .utf8)!
        
        let ciphers = try (0..<numCiphers).map { _ in
            try Cipher(js: js)
        }

        // Create multiple Cipher instances concurrently, each calling calculateN
        // This matches real usage where each YouTube object creates its own Cipher
        try await withThrowingTaskGroup(of: String.self) { group in
            for i in 0..<numCiphers {
                group.addTask {
                    let cipher = ciphers[i] //try Cipher(js: js)
                    print("started at \(Date())")
                    defer { print("finished at \(Date())") }
                    return try cipher.calculateN(initialN: input)
                }
            }

            // Verify all outputs match expected
            for try await output in group {
                XCTAssertEqual(output, expectedOutput)
            }
        }
    }

}
