//
//  ExtractionTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import XCTest
@testable import YouTubeKit

@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
final class ExtractionTests: XCTestCase {
    
    func testExtractVideoID() {
        let url = "https://www.youtube.com/watch?v=2lAe1cqCOXo"
        let videoID = Extraction.extractVideoID(from: url)
        XCTAssertEqual(videoID, "2lAe1cqCOXo")
    }
    
}
