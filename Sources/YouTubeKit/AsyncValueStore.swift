//
//  AsyncValueStore.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 14.03.26.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
actor AsyncValueStore<Key: Hashable & Sendable, Value: Sendable> {
    private var ready = [Key: Value]()
    private var inFlight = [Key: Task<Value, Error>]()

    func value(for key: Key, loader: @escaping @Sendable () async throws -> Value) async throws -> Value {
        if let cached = ready[key] {
            return cached
        }

        if let task = inFlight[key] {
            return try await task.value
        }

        let task = Task {
            try await loader()
        }
        inFlight[key] = task

        do {
            let value = try await task.value
            ready[key] = value
            inFlight[key] = nil
            return value
        } catch {
            inFlight[key] = nil
            throw error
        }
    }
}
