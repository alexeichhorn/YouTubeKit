//
//  AsyncCompatibility.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 14.12.21.
//

import Foundation

/// Thread-safe holder tying an in-flight `URLSessionTask` to Swift task cancellation.
/// If the surrounding Swift task is cancelled before the URLSessionTask is registered,
/// the URLSessionTask is cancelled immediately upon registration.
private final class URLSessionTaskCancellationBox: @unchecked Sendable {
    private let lock = NSLock()
    private var task: URLSessionTask?
    private var isCancelled = false

    func register(_ task: URLSessionTask) {
        lock.lock()
        self.task = task
        let cancelled = isCancelled
        lock.unlock()
        if cancelled {
            task.cancel()
        }
    }

    func cancel() {
        lock.lock()
        isCancelled = true
        let task = self.task
        lock.unlock()
        task?.cancel()
    }
}

/// Backward compatibility of iOS 15 URLSession async function for older versions.
/// Cancellation-aware: cancelling the surrounding Swift task cancels the underlying
/// `URLSessionTask` (the request fails with `URLError.cancelled`) instead of letting
/// the download run to completion.
@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension URLSession {

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await performCancellableDataTask { dataTask(with: url, completionHandler: $0) }
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await performCancellableDataTask { dataTask(with: request, completionHandler: $0) }
    }

    /// Shared body for the async shims: bridge a completion-handler `dataTask` to
    /// async, cancelling the underlying `URLSessionTask` when the Swift task is cancelled.
    private func performCancellableDataTask(
        _ makeTask: (@escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    ) async throws -> (Data, URLResponse) {
        let box = URLSessionTaskCancellationBox()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let task = makeTask { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.unknown)
                        return continuation.resume(throwing: error)
                    }

                    continuation.resume(returning: (data, response))
                }
                box.register(task)
                task.resume()
            }
        } onCancel: {
            box.cancel()
        }
    }

}
