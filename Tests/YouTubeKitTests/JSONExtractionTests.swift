import XCTest
@testable import YouTubeKit

final class JSONExtractionTests: XCTestCase {
    func testCombiningMarkAfterOpeningQuoteDoesNotConsumeFollowingScript() throws {
        // The real failing video has this standalone Kayah Li tone mark in its tags.
        // Swift Character groups it with the opening quote; JSON syntax uses scalar boundaries.
        let json = #"{"tags":["꤬"],"playabilityStatus":{"status":"OK"}}"#
        let html = "var ytInitialPlayerResponse = " + json + ";var following = {\"unrelated\":true};"
        let start = try XCTUnwrap(html.range(of: json)?.lowerBound)
        XCTAssertEqual(try Extraction.findObjectFromStartpoint(html: html, startPoint: start), json)
        let response = try Extraction.initialPlayerResponse(watchHTML: html)
        XCTAssertEqual(response.playabilityStatus?.status, .ok)
    }

    func testNestedArraysEscapesAndUnicode() throws {
        let json = #"{"items":[{"text":"escaped \" } ] \\ and 😀"}],"text":"é"}"#
        let html = "😀 prefix " + json + ";not JSON"
        let start = try XCTUnwrap(html.range(of: json)?.lowerBound)
        XCTAssertEqual(try Extraction.findObjectFromStartpoint(html: html, startPoint: start), json)
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: Data(json.utf8)))
    }

    func testRootArray() throws {
        let json = #"[{"value":"꤬"},[1,2]]"#
        let html = json + ";next()"
        XCTAssertEqual(try Extraction.findObjectFromStartpoint(html: html, startPoint: html.startIndex), json)
    }

    func testRejectsIncompleteOrMismatchedJSON() {
        for json in ["{", "[}", #"{"text":"unfinished"#, #"{"text":"trailing\"#] {
            XCTAssertThrowsError(try Extraction.findObjectFromStartpoint(html: json, startPoint: json.startIndex))
        }
    }
}
