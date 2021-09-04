import XCTest
@testable import YouTubeKit

final class YouTubeKitTests: XCTestCase {
    
    func testVideoUnavailable() async {
        let youtube = YouTube(videoID: "cTsNJNx7plQ")
        do {
            try await youtube.checkAvailability()
            XCTFail("Expected throw")
        } catch let error {
            XCTAssertEqual(error as? YouTubeKitError, .videoPrivate)
        }
    }
    
    func testVideoAvailable() async {
        let youtube = YouTube(videoID: "9bZkp7q19f0")
        do {
            try await youtube.checkAvailability()
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
}
