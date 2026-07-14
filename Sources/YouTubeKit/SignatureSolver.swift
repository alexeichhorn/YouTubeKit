//
//  SignatureSolver.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.10.2025.
//

import Foundation
#if canImport(JavaScriptCore)
import JavaScriptCore
import os.log

class SignatureSolver {

    private static let log = OSLog(SignatureSolver.self)

    // MARK: Shared instance cache
    // Solver construction (JSContext + meriyah/astring bundle eval) and the first
    // solve (full player parse) are very expensive on JIT-less platforms (tvOS/iOS
    // JavaScriptCore runs interpreted). Cache one solver per player-JS version so
    // subsequent videos reuse the context and the preprocessed player.
    private static let sharedLock = NSLock()
    /// Small most-recently-used cache of solvers keyed by their player JS.
    /// Bounded because each solver retains a JSContext and the ~2 MB player;
    /// a session rarely uses more than a couple of player variants (e.g. web
    /// vs TV/embed), so alternating between them still reuses each solver.
#if swift(>=5.10)
    nonisolated(unsafe) private static var sharedSolvers: [SignatureSolver] = []
#else
    private static var sharedSolvers: [SignatureSolver] = []
#endif
    private static let maxCachedSolvers = 4

    static func shared(forJS js: String) throws -> SignatureSolver {
        sharedLock.lock()
        defer { sharedLock.unlock() }
        // Match on the retained player JS directly — Swift string equality is
        // pointer-identity-fast in the common case and avoids the hash-collision
        // risk of caching by hashValue (a collision would return a wrong solver).
        if let idx = sharedSolvers.firstIndex(where: { $0.playerJS == js }) {
            let solver = sharedSolvers.remove(at: idx)
            sharedSolvers.insert(solver, at: 0) // promote to most-recently-used
            return solver
        }
        // A task can be cancelled while blocked on the lock; bail before the
        // expensive init rather than tying up the thread pool.
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
            try Task.checkCancellation()
        }
        let start = Date()
        let solver = try SignatureSolver(js: js)
        os_log("solver init took %.2fs", log: log, type: .default, Date().timeIntervalSince(start))
        sharedSolvers.insert(solver, at: 0)
        if sharedSolvers.count > maxCachedSolvers {
            sharedSolvers.removeLast()
        }
        return solver
    }

    /// Player preprocessed by the first solve; skips the full player parse afterwards
    private var preprocessedPlayer: String?
    /// JSContext isn't thread-safe; the shared instance serializes solves
    private let solveLock = NSLock()

    private let vm = JSVirtualMachine()
    private let ctx: JSContext
    
    private let playerJS: String
    
    init(js: String) throws {
        self.playerJS = js
        
        guard let context = JSContext(virtualMachine: vm) else {
            throw SignatureSolverError.contextCreationFailed
        }
        ctx = context
        ctx.exceptionHandler = { _, exc in
            os_log("JSC error: %{public}@", log: Self.log, type: .error, exc?.toString() ?? "<unknown>")
        }
        
        // Minimal DOM/env shims (matches `setupNodes`)
        ctx.evaluateScript(#"""
            globalThis.XMLHttpRequest = { prototype: {} };
            globalThis.URL = class URL {
                constructor(url) {
                    this.href = url;
                    const match = url.match(/^(https?:)\/\/([^/:]+)(:(\d+))?(\/[^?#]*)?(\?[^#]*)?(#.*)?$/);
                    this.protocol = match ? match[1] : '';
                    this.hostname = match ? match[2] : '';
                    this.port = match && match[4] ? match[4] : '';
                    this.pathname = match && match[5] ? match[5] : '/';
                    this.search = match && match[6] ? match[6] : '';
                    this.hash = match && match[7] ? match[7] : '';
                }
            };
            globalThis.navigator = {
                userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
            };
            const window = Object.assign(Object.create(null), globalThis);
            window.location = new URL("https://www.youtube.com/watch?v=youtubekit-wins");
            const document = {};
            let self = globalThis;
        """#)
        
        // Load meriyah + astring UMD bundles from package resources
        func evalResource(_ name: String, _ ext: String) throws {
            guard let url = Bundle.module.url(forResource: name, withExtension: ext) else {
                throw SignatureSolverError.resourceNotFound(name: name, extension: ext)
            }
            let src = try String(contentsOf: url, encoding: .utf8)
            ctx.evaluateScript(src)
        }
        try evalResource("meriyah", "umd.js")
        try evalResource("astring", "umd.js")
        
        // Load generated yt-ejs helper
        try evalResource("yt_ejs_helper", "js")
    }
    
    private struct Request: Codable {
        let type: RequestType
        let challenges: [String]
        
        enum RequestType: String, Codable {
            case n, sig
        }
    }
    
    private struct Input: Codable {
        let type: PlayerType
        let player: String? // raw player JS if type == .player
        let preprocessed_player: String? // otherwise
        let requests: [Request]
        let output_preprocessed: Bool?
        
        enum PlayerType: String, Codable {
            case player
            case preprocessedPlayer = "preprocessed_player"
        }
    }
    
    private struct Response: Codable {
        struct Item: Codable {
            let type: ItemType
            let data: [String: String]?
            let error: String?
            
            enum ItemType: String, Codable {
                case result
                case error
            }
        }
        let type: String
        let responses: [Item]
        let preprocessed_player: String?
    }
    
    private func solve(with input: Input) throws -> Response {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let json = try String(data: encoder.encode(input), encoding: .utf8)!
        
        // Call the global `jsc` function defined by yt-ejs
        ctx.setObject(json, forKeyedSubscript: "swiftInput" as NSString)
        let js = "JSON.stringify(jsc(JSON.parse(swiftInput)))"
        guard let result = ctx.evaluateScript(js) else {
            throw SignatureSolverError.evaluationFailed
        }
        
        guard let out = result.toString() else {
            throw SignatureSolverError.resultConversionFailed
        }
        
        guard let data = out.data(using: .utf8) else {
            throw SignatureSolverError.encodingFailed
        }
        
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            os_log("JSC output was: %{public}@", log: Self.log, type: .error, out)
            throw SignatureSolverError.jsonDecodingFailed(error)
        }
    }
    
    // MARK: - Public
    
    struct SolveRequest {
        var nInputs: [String]
        var sigInputs: [String]
    }
    
    struct SolveResponse {
        let nMap: [String: String]
        let sigMap: [String: String]
    }
    
    func batchSolve(request: SolveRequest) throws -> SolveResponse {
        solveLock.lock()
        defer { solveLock.unlock() }

        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
            try Task.checkCancellation()
        }

        let requests = [
            Request(type: .n, challenges: request.nInputs),
            Request(type: .sig, challenges: request.sigInputs)
        ]

        let input: Input
        if let preprocessedPlayer {
            input = Input(
                type: .preprocessedPlayer,
                player: nil,
                preprocessed_player: preprocessedPlayer,
                requests: requests,
                output_preprocessed: false
            )
        } else {
            input = Input(
                type: .player,
                player: self.playerJS,
                preprocessed_player: nil,
                requests: requests,
                output_preprocessed: true
            )
        }

        let solveStart = Date()
        let response = try solve(with: input)
        os_log("batch solve took %.2fs (preprocessed: %{public}@)", log: Self.log, type: .default, Date().timeIntervalSince(solveStart), preprocessedPlayer != nil ? "yes" : "no")

        if preprocessedPlayer == nil {
            preprocessedPlayer = response.preprocessed_player
        }

        var nMap: [String: String] = [:]
        var sigMap: [String: String] = [:]

        // Responses come back in same order as requests
        for (request, item) in zip(requests, response.responses) {
            switch item.type {
            case .error:
                if let error = item.error {
                    throw SignatureSolverError.solverError(requestType: request.type.rawValue, message: error)
                }
            case .result:
                if let data = item.data {
                    switch request.type {
                    case .n:
                        nMap.merge(data) { _, new in new }
                    case .sig:
                        sigMap.merge(data) { _, new in new }
                    }
                }
            }
        }

        return SolveResponse(nMap: nMap, sigMap: sigMap)
    }
}
#endif
