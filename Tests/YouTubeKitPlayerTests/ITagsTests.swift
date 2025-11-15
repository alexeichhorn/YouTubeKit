//
//  ITagsTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 06.09.21.
//

import XCTest
@testable import YouTubeKit

final class ITagsTests: XCTestCase {
    
    func testSampleProfile() {
        guard let itag = ITag(22) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(itag.videoResolution, 720)
        XCTAssertEqual(itag.audioBitrate, 192)
        XCTAssertEqual(itag.isDash, false)
        XCTAssertFalse(itag.is3D)
        XCTAssertFalse(itag.isHDR)
        XCTAssertFalse(itag.isLive)
    }
    
    func testNonExistentProfile() {
        let itag = ITag(2239)
        XCTAssertNil(itag)
    }
    
}
