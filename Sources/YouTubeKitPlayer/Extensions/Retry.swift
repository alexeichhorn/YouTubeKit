//
//  Retry.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 31.08.23.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension Task {
    
    fileprivate enum RetryError: Error {
        case emptyMethods
    }
    
    // A static function that attempts to execute a block of code with each method in a provided array.
    // If the block throws an error, the function will try the next method.
    // If all methods have been tried and all have thrown errors, the function will throw the last error encountered.
    static func retry<Method>(with methods: [Method], block: (Method) async throws -> Success) async throws -> Success where Failure == Never {
        
        var lastError: any Error = RetryError.emptyMethods
        
        for method in methods {
            do {
                return try await block(method)
            } catch let error {
                lastError = error
            }
        }
        
        throw lastError
    }
    
}
