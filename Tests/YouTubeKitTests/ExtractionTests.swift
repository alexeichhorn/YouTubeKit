//
//  ExtractionTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import XCTest
@testable import YouTubeKit

final class ExtractionTests: XCTestCase {
    
    func testExtractVideoID() {
        let url = "https://www.youtube.com/watch?v=2lAe1cqCOXo"
        let videoID = Extraction.extractVideoID(from: url)
        XCTAssertEqual(videoID, "2lAe1cqCOXo")
    }
    
}
