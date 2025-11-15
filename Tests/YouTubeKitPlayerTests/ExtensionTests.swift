//
//  ExtensionTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 20.01.22.
//

import XCTest
@testable import YouTubeKit

final class ExtensionTests: XCTestCase {
    
    func testLazyPropertyWrapper() {
        
        @Lazy var randomNumber = Int.random(in: 0..<1_000_000_000)
        XCTAssertEqual(randomNumber, randomNumber)
        
        @Lazy var fixedNumber = 8
        XCTAssertEqual(fixedNumber, 8)
        fixedNumber *= 10
        XCTAssertEqual(fixedNumber, 80)
        
        @Lazy var lazyObject = NSObject()
        XCTAssert(lazyObject === lazyObject)
    }
    
    func testThrowingLazyWrapper() {
        
        // - non-throwing tests
        
        var randomNumber = ThrowingLazy(Int.random(in: 0..<1_000_000_000))
        XCTAssertEqual(try randomNumber.value, try randomNumber.value)
        
        var fixedNumber = ThrowingLazy(8)
        XCTAssertEqual(try fixedNumber.value, 8)
        
        var lazyObject = ThrowingLazy(NSObject())
        XCTAssert(try lazyObject.value === lazyObject.value)
        
        
        // - throwing tests
        
        enum TestError: Error {
            case first, second
        }
        
        var throwingRandomNumber = ThrowingLazy(try Result<Int, Error>.failure(TestError.first).get())
        XCTAssertThrowsError(try throwingRandomNumber.value, "Didn't throw an error") { error in
            XCTAssertEqual(error as? TestError, TestError.first)
        }
        
        func randomThrowingFunction() throws -> Int {
            if Bool.random() {
                return Int.random(in: 0..<1_000_000_000)
            }
            throw Bool.random() ? TestError.first : TestError.second
        }
        
        for _ in 0..<100 { // test multiple times
            var randomThrowingValue = ThrowingLazy(try randomThrowingFunction())
            do {
                let value = try randomThrowingValue.value
                XCTAssertNoThrow(try randomThrowingValue.value)
                XCTAssertEqual(value, try randomThrowingValue.value)
            } catch let error {
                XCTAssertThrowsError(try randomThrowingValue.value, "Didn't throw error second time") { secondError in
                    XCTAssertEqual(error as? TestError, secondError as? TestError)
                }
            }
        }
    }
    
    
    func testStringStrip() {
        
        XCTAssertEqual("xD".strip(from: "x"), "D")
        XCTAssertEqual("[[8810dja3kj]]]]]]28dsalk".strip(from: "[]"), "8810dja3kj28dsalk")
        XCTAssertEqual("sahdaläösdsdsü".strip(from: "ööööüöööö"), "sahdaläsdsds")
        
    }
    
}
