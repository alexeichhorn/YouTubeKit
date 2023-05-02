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
    
}
