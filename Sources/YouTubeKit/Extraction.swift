//
//  Extraction.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation
import os.log

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
class Extraction {
    
    private static let log = OSLog(Extraction.self)
    
    class func extractVideoID(from url: String) -> String? {
        let regex = NSRegularExpression(#"(?:v=|\/)([0-9A-Za-z_-]{11}).*"#)
        return regex.firstMatch(in: url, group: 1)?.content
    }
    
    class func isAgeRestricted(watchHTML: String) -> Bool {
        let regex = NSRegularExpression(#"og:restrictions:age"#)
        return regex.firstMatch(in: watchHTML, group: 0) != nil
    }
    
    
    /// Allows to override player id in case we have a (currently) unsolvable in the future
    private static let PLAYER_ID_OVERRIDE: String? = nil
    private static let PLAYER_STS_OVERRIDE: Int? = nil

    /// Get the base JavaScript url
    class func jsURL(html: String) throws -> String {
        let baseURL = try (try? getYTPlayerConfig(html: html).assets?.js)
                           ?? (try getYTPlayerJS(html: html))

        // Replace potentially broken player ID with known working one
        // Format: /s/player/{PLAYER_ID}/{VARIANT_PATH}
        let playerIDPattern = NSRegularExpression(#"(/s/player/)([a-zA-Z0-9_]+)(/.*)"#)
        if let PLAYER_ID_OVERRIDE,
           let (_, groupMatches) = playerIDPattern.firstMatch(in: baseURL, includingGroups: [1, 2, 3]),
           let prefix = groupMatches[1]?.content,
           let _ = groupMatches[2]?.content,
           let suffix = groupMatches[3]?.content {
            let fixedURL = prefix + PLAYER_ID_OVERRIDE + suffix
            return "https://youtube.com" + fixedURL
        }

        // Fallback to extracted URL if pattern doesn't match (shouldn't happen)
        return "https://youtube.com" + baseURL
    }
    
    /// Get the YouTube player base JavaScript path.
    class func getYTPlayerJS(html: String) throws -> String {
        let jsURLPatterns = [
            NSRegularExpression(#"(/s/player/[\w\d]+/[\w\d_/.]+/base\.js)"#)
        ]
        
        for pattern in jsURLPatterns {
            if let match = pattern.firstMatch(in: html, group: 1) {
                return match.content
            }
        }
        
        throw YouTubeKitError.regexMatchError
    }
    
    struct PlayerConfig: Decodable {
        let assets: Assets?
        
        struct Assets: Decodable {
            let js: String?
        }
    }
    
    /// Get the YouTube player configuration data from the watch/embed html
    class func getYTPlayerConfig(html: String) throws -> PlayerConfig {
        os_log("finding initial function name", log: log, type: .debug)
        let configPatterns = [
            NSRegularExpression(#"ytplayer\.config\s*=\s*"#),
            NSRegularExpression(#"ytInitialPlayerResponse\s*=\s*"#)
        ]
        
        for pattern in configPatterns {
            do {
                return try parseForObject(PlayerConfig.self, html: html, precedingRegex: pattern)
            } catch let error {
                os_log("pattern (%{public}@) failed: %{public}@", log: log, type: .debug, pattern.pattern, error.localizedDescription)
                continue
            }
        }
        
        let setConfigPatterns = [
            NSRegularExpression(#"yt\.setConfig\(.*['\"]PLAYER_CONFIG['\"]:\s*"#)
        ]
        
        for pattern in setConfigPatterns {
            do {
                return try parseForObject(PlayerConfig.self, html: html, precedingRegex: pattern)
            } catch {
                continue
            }
        }
        
        throw YouTubeKitError.regexMatchError
    }
    
    /// Tries to find video info in watch html directly
    class func getVideoInfo(fromHTML html: String) throws -> InnerTube.VideoInfo {
        let pattern = NSRegularExpression(#"ytInitialPlayerResponse\s*=\s*"#)
        return try parseForObject(InnerTube.VideoInfo.self, html: html, precedingRegex: pattern)
    }
    
    /// Return the playability status and status explanation of the video
    /// For example, a video may have a status of LOGIN\_REQUIRED, and an explanation
    /// of "This is a private video. Please sign in to verify that you may see it."
    /// - parameter watchHTML: The html contents of the watch page
    /// - returns: playability status and reason of the video
    class func playabilityStatus(watchHTML: String) throws -> (InitialPlayerResponse.PlayabilityStatus.Status?, [String?]) {
        let playerResponse = try initialPlayerResponse(watchHTML: watchHTML)
        let status = playerResponse.playabilityStatus
        if status?.liveStreamability != nil {
            return (.liveStream, ["Video is a live stream"])
        } else if let currentStatus = status?.status {
            if let reason = status?.reason {
                return (currentStatus, [reason])
            } else if let messages = status?.messages {
                return (currentStatus, messages)
            }
        }
        return (nil, [nil])
    }
    
    /// Extracts the signature timestamp (sts) from javascript.
    /// Used to pass into InnerTube to tell API what sig/player is in use.
    /// - parameter js: The javascript contents of the watch page
    /// - returns: The signature timestamp (sts) or nil if not found
    class func extractSignatureTimestamp(fromJS js: String) -> Int? {
        // Return hardcoded STS that matches overridden player
        if let PLAYER_STS_OVERRIDE {
            return PLAYER_STS_OVERRIDE
        }

        let pattern = NSRegularExpression(#"(?:signatureTimestamp|sts)\s*:\s*([0-9]{5})"#)
        if let match = pattern.firstMatch(in: js, group: 1) {
            return Int(match.content)
        }
        return nil
    }
    
    struct YtCfg: Decodable {
        let VISITOR_DATA: String?
        let INNERTUBE_CONTEXT: Context?
        
        struct Context: Decodable {
            let client: Client
            
            struct Client: Decodable {
                let visitorData: String?
                let userAgent: String?
            }
        }
        
        var visitorData: String? {
            VISITOR_DATA ?? INNERTUBE_CONTEXT?.client.visitorData
        }
        
        var userAgent: String? {
            INNERTUBE_CONTEXT?.client.userAgent
        }
    }
    
    class func extractYtCfg(from html: String) throws -> YtCfg {
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            let regex = #/ytcfg\.set\s*\(\s*(?={)/#
            let cfg = try parseForObject(YtCfg.self, html: html, precedingRegex: regex)
            return cfg
        } else {
            let regex = NSRegularExpression(#"ytcfg\.set\s*\(\s*"#)
            let cfg = try parseForObject(YtCfg.self, html: html, precedingRegex: regex)
            return cfg
        }
    }
    
    /// Parses input html to find the end of a JavaScript object.
    /// - parameter html: HTML to be parsed for an object.
    /// - parameter precedingRegex: Regex to find the string preceding the object.
    /// - returns: A decodable object
    class func parseForObject<T: Decodable>(_ type: T.Type, html: String, precedingRegex: NSRegularExpression) throws -> T {
        let results = precedingRegex.allMatches(in: html)
        
        for result in results {
            let startIndex = result.end
            do {
                return try parseForObjectFromStartpoint(type, html: html, startPoint: startIndex)
            } catch {
                
            }
        }
        
        throw YouTubeKitError.htmlParseError
    }
    
    /// Parses input html to find the end of a JavaScript object.
    /// - parameter html: HTML to be parsed for an object.
    /// - parameter precedingRegex: Regex to find the string preceding the object.
    /// - returns: A decodable object
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    class func parseForObject<T: Decodable>(_ type: T.Type, html: String, precedingRegex: Regex<Substring>) throws -> T {
        let results = html.matches(of: precedingRegex)
        
        for result in results {
            let startIndex = result.endIndex
            do {
                return try parseForObjectFromStartpoint(type, html: html, startPoint: startIndex)
            } catch {
                
            }
        }
        
        throw YouTubeKitError.htmlParseError
    }
    
    /// Parses input html to find the end of a JavaScript object.
    class func findObjectFromStartpoint(html fullHTML: String, startPoint: String.Index) throws -> String {
        let html = String(fullHTML[startPoint...])
        guard ["{", "["].contains(html.first ?? " ") else {
            throw YouTubeKitError.htmlParseError
        }
        
        var stack = [html.first!]
        var i = html.index(after: html.startIndex)
        
        let contextClosers: [Character: Character] = [
            "{": "}",
            "[": "]",
            "\"": "\""
        ]
        
        let endIndex = html.endIndex
        while i < endIndex {
            guard let currentContext = stack.last else {
                break
            }
            let currentChar = html[i]
            
            // current context gets closed
            if currentChar == contextClosers[currentContext] {
                _ = stack.popLast()
                i = html.index(after: i)
                continue
            }
            
            // strings require special context handling because they can contain context openers and closers
            if currentContext == "\"" {
                if currentChar == "\\" {
                    i = html.index(i, offsetBy: 2)
                    continue
                }
            } else {
                // non-string contexts are when we need to look for context openers
                if contextClosers.keys.contains(currentChar) {
                    stack.append(currentChar)
                }
            }
            
            i = html.index(after: i)
        }
        
        let fullObject = String(html[..<i])
        return fullObject
    }
    
    /// JSONifies an object parsed from HTML.
    /// - parameter html: HTML to be parsed for an object
    /// - parameter startPoint: Index of where the object starts
    /// - returns: A dict created from parsing the object
    class func parseForObjectFromStartpoint<T: Decodable>(_ type: T.Type, html: String, startPoint: String.Index) throws -> T {
        let fullObject = try findObjectFromStartpoint(html: html, startPoint: startPoint)
        let objectData = fullObject.data(using: .utf8) ?? Data()
        
        do {
            return try JSONDecoder().decode(type, from: objectData)
        } catch let error {
            // TODO: try different evaluation (like in Python: ast.literal_eval)
            os_log("Failed to decode object from given start point: %{public}@", log: log, type: .error, error.localizedDescription)
            throw YouTubeKitError.htmlParseError
        }
    }
    
    struct InitialPlayerResponse: Decodable {
        let playabilityStatus: PlayabilityStatus?
        
        struct PlayabilityStatus: Decodable {
            let status: Status?
            let reason: String?
            let messages: [String]?
            let liveStreamability: LiveStreamabilityRenderer?

            enum Status: String, Decodable {
                case ok = "OK"
                case unplayable = "UNPLAYABLE"
                case loginRequired = "LOGIN_REQUIRED"
                case error = "ERROR"
                case liveStream = "LIVE_STREAM"
            }

            struct LiveStreamabilityRenderer: Decodable {
                let videoId: String?
                let broadcastId: Int?
                let pillDelayMs: Int?
            }
        }
    }
    
    /// Extract the ytInitialPlayerResponse json from the watch html page.
    /// This mostly contains metadata necessary for rendering the page on-load,
    /// such as video information, copyright notices, etc.
    /// - parameter watchHTML: The html contents of the watch page
    class func initialPlayerResponse(watchHTML: String) throws -> InitialPlayerResponse {
        let patterns = [
            NSRegularExpression(#"window\[['\"]ytInitialPlayerResponse['\"]]\s*=\s*"#),
            NSRegularExpression(#"ytInitialPlayerResponse\s*=\s*"#)
        ]
        for pattern in patterns {
            do {
                return try parseForObject(InitialPlayerResponse.self, html: watchHTML, precedingRegex: pattern)
            } catch {
                
            }
        }
        
        throw YouTubeKitError.regexMatchError
    }
    
    class func parseQueryString(_ queryString: String) -> [String: [String]] {
        var components = URLComponents()
        components.query = queryString
        var result = [String: [String]]()
        for queryItem in components.queryItems ?? [] {
            if let value = queryItem.value {
                result[queryItem.name, default: []].append(value)
            }
        }
        return result
    }
    
    class func applyDescrambler(streamData: InnerTube.StreamingData) -> [InnerTube.StreamingData.Format] {
        /*if streamData.keys.contains("url") {
            return nil
        }*/
        
        var formats = [InnerTube.StreamingData.Format]()
        if let streamFormats = streamData.formats {
            formats += streamFormats
        }
        if let adaptiveFormats = streamData.adaptiveFormats {
            formats += adaptiveFormats
        }
        
        for (i, data) in formats.enumerated() {
            if data.url == nil {
                if let signatureCipher = data.signatureCipher {
                    let cipherURL = parseQueryString(signatureCipher)
                    // URL-decode the values (they come percent-encoded from signatureCipher)
                    formats[i].url = cipherURL["url"]?.first?.removingPercentEncoding ?? cipherURL["url"]?.first
                    formats[i].s = cipherURL["s"]?.first?.removingPercentEncoding ?? cipherURL["s"]?.first
                    formats[i].sp = cipherURL["sp"]?.first?.removingPercentEncoding ?? cipherURL["sp"]?.first
                }
            }
        }
        
        os_log("applying descrambler", log: log, type: .debug)
        return formats
    }
    
#if canImport(JavaScriptCore)
    /// apply the decrypted signature to the stream manifest
    class func applySignature(streamManifest: inout [InnerTube.StreamingData.Format], videoInfo: InnerTube.VideoInfo, js: String) throws {
        let solver = try SignatureSolver(js: js)

        var sigInputs: [String] = []
        var nInputs: [String] = []

        // First pass: collect all inputs
        for stream in streamManifest {
            if let url = stream.url {
                guard let urlComponents = URLComponents(string: url) else { continue }

                let signatureFound = url.contains("signature") || (stream.s == nil && (url.contains("&sig=") || url.contains("&lsig=")))

                if !signatureFound {
                    if let cipheredSignature = stream.s {
                        sigInputs.append(cipheredSignature)
                    }
                }

                if let initialN = urlComponents.queryItems?["n"] {
                    nInputs.append(initialN)
                }
            }
        }

        // Batch solve all signatures and n-parameters
        let request = SignatureSolver.SolveRequest(nInputs: nInputs, sigInputs: sigInputs)
        let response = try solver.batchSolve(request: request)

        var invalidStreamIndices = [Int]()

        // Second pass: apply results
        for (i, stream) in streamManifest.enumerated() {
            if let url = stream.url {
                guard var urlComponents = URLComponents(string: url) else { continue } // TODO: fail differently

                if urlComponents.queryItems == nil {
                    urlComponents.queryItems = []
                }

                let signatureFound = url.contains("signature") || (stream.s == nil && (url.contains("&sig=") || url.contains("&lsig=")))

                if !signatureFound {

                    // apply "s" signature
                    if let cipheredSignature = stream.s {
                        guard let signature = response.sigMap[cipheredSignature] else {
                            os_log("failed to decrypt signature for itag=%{public}i, removing stream", log: log, type: .error, stream.itag)
                            invalidStreamIndices.append(i)
                            continue
                        }

                        os_log("finished descrambling signature for itag=%{public}i", log: log, type: .debug, stream.itag)

                        // Use sp parameter name from signatureCipher, default to "signature" if not present
                        let paramName = stream.sp ?? "signature"
                        urlComponents.queryItems?[paramName] = signature
                    }

                } else {
                    // os_log("signature found, skip decipher", log: log, type: .debug)
                }


                // apply throttling "n" signature
                if let initialN = urlComponents.queryItems?["n"] {
                    guard let newN = response.nMap[initialN] else {
                        invalidStreamIndices.append(i)
                        continue
                    }
                    urlComponents.queryItems?["n"] = newN

                    if newN.isEmpty {
                        invalidStreamIndices.append(i)
                    }
                }


                let url = urlComponents.url?.absoluteString ?? url
                streamManifest[i].url = url
            }
        }

        // Remove invalid streams
        for index in invalidStreamIndices.reversed() {
            streamManifest.remove(at: index)
        }
    }
#endif
    
    /// Filter out all audio streams that are not original language (i.e. dubbed)
    class func filterOutDubbedAudio(streamManifest: [InnerTube.StreamingData.Format]) -> [InnerTube.StreamingData.Format] {
        streamManifest.filter { stream in
            if let audioTrack = stream.audioTrack {
                return audioTrack.displayName.lowercased().hasSuffix("original")
            }
            return true
        }
    }
    
    /// Breaks up the data in the ``type`` key of the manifest, which contains the
    /// mime type and codecs serialized together, and splits them into separate elements.
    /// _Example_: mimeTypeCodec(#"audio/webm; codecs="opus""#) -> ("audio/webm", ["opus"])
    class func mimeTypeCodec(_ mimeTypeCodec: String) throws -> (String, [String]) {
        let regex = NSRegularExpression(#"(\w+\/\w+)\;\scodecs=\"([a-zA-Z-0-9.,\s]*)\""#)
        if let mimeTypeResult = regex.firstMatch(in: mimeTypeCodec, group: 1),
           let codecsResult = regex.firstMatch(in: mimeTypeCodec, group: 2) {
            return (mimeTypeResult.content, codecsResult.content.split(separator: ",").map { String($0).strip(from: " ") })
        }
        throw YouTubeKitError.regexMatchError
    }
    
}
