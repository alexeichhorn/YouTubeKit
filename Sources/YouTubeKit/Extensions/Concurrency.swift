//
//  Concurrency.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 13.12.23.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension Sequence {
    
    func asyncMap<T: Sendable>(_ transform: (Element) async throws -> T, isolation: isolated (any Actor)? = #isolation) async rethrows -> [T] where Element: Sendable {
        var values = [T]()
        
        for element in self {
            try await values.append(transform(element))
        }
        
        return values
    }
    
    func concurrentMap<T: Sendable>(_ transform: @Sendable (Element) async -> T) async -> [T] where Element: Sendable {
        return await withoutActuallyEscaping(transform) { escapingTransform in
            
            let tasks = map { element in
                Task {
                    await escapingTransform(element)
                }
            }
            
            return await tasks.asyncMap { task in
                await task.value
            }
        }
    }
    
}
