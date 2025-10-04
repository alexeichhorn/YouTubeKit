//
//  SignatureSolver.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.10.2025.
//

import Foundation
import JavaScriptCore

class SignatureSolver {
    
    private let vm = JSVirtualMachine()
    private let ctx: JSContext
    
    private let playerJS: String
    
    init(js: String) throws {
        self.playerJS = js
        
        guard let context = JSContext(virtualMachine: vm) else {
            throw NSError(domain: "JSC", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to make JSContext"])
        }
        ctx = context
        ctx.exceptionHandler = { _, exc in
            print("JSC error:", exc?.toString() ?? "<unknown>")
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
            window.location = new URL("https://www.youtube.com/watch?v=yt-dlp-wins");
            const document = {};
            let self = globalThis;
        """#)
        
        // Load meriyah + astring UMD bundles from package resources
        func evalResource(_ name: String, _ ext: String) throws {
            guard let url = Bundle.module.url(forResource: name, withExtension: ext) else {
                throw NSError(domain: "JSC", code: 3, userInfo: [NSLocalizedDescriptionKey: "Resource not found: \(name).\(ext)"])
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
            let type: Request.RequestType
            let data: [String: String]?
            let error: String?
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
            throw NSError(domain: "JSC", code: 2, userInfo: [NSLocalizedDescriptionKey: "JavaScript evaluation returned null"])
        }
        
        guard let out = result.toString() else {
            throw NSError(domain: "JSC", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert result to string"])
        }
        
        guard let data = out.data(using: .utf8) else {
            throw NSError(domain: "JSC", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode output as UTF-8"])
        }
        
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            print("JSC output was: \(out)")
            throw NSError(domain: "JSC", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Failed to decode JSON response",
                NSLocalizedFailureReasonErrorKey: error.localizedDescription
            ])
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

        let input = Input(
            type: .player,
            player: self.playerJS,
            preprocessed_player: nil,
            requests: [
                Request(type: .n, challenges: request.nInputs),
                Request(type: .sig, challenges: request.sigInputs)
            ],
            output_preprocessed: false
        )

        let response = try solve(with: input)

        var nMap: [String: String] = [:]
        var sigMap: [String: String] = [:]

        for item in response.responses {
            // Check for errors
            if let error = item.error {
                throw NSError(domain: "SignatureSolver", code: 4, userInfo: [
                    NSLocalizedDescriptionKey: "Solver error for type \(item.type): \(error)"
                ])
            }

            // Process data
            if let data = item.data {
                switch item.type {
                case .n:
                    nMap.merge(data) { _, new in new }
                case .sig:
                    sigMap.merge(data) { _, new in new }
                }
            }
        }

        return SolveResponse(nMap: nMap, sigMap: sigMap)
    }
}

