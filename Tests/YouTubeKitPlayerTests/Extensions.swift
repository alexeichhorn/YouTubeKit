//
//  Extensions.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 25.01.22.
//

import XCTest

//XCTAssertNoThrow<T>(_ expression: @autoclosure () throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line)

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
func XCTAssertNoThrow<T>(_ expression: @autoclosure () async throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) async {
    do {
        _ = try await expression()
    } catch let error {
        XCTFail(message() + " - did throw error \(error)", file: file, line: line)
    }
}
