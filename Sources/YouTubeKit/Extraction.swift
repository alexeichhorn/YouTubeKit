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
    
    
    /// Get the base JavaScript url
    class func jsURL(html: String) throws -> String {
        let baseURL = try (try? getYTPlayerConfig(html: html).assets?.js)
                           ?? (try getYTPlayerJS(html: html))
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
                    formats[i].url = cipherURL["url"]?.first
                    formats[i].s = cipherURL["s"]?.first
                }
            }
        }
        
        os_log("applying descrambler", log: log, type: .debug)
        return formats
    }
    
    /// apply the decrypted signature to the stream manifest
    class func applySignature(streamManifest: inout [InnerTube.StreamingData.Format], videoInfo: InnerTube.VideoInfo, js: String) throws {
        var cipher = ThrowingLazy(try Cipher(js: js))
        
        var invalidStreamIndices = [Int]()
        
        for (i, stream) in streamManifest.enumerated() {
            if let url = stream.url {
                if url.contains("signature") || (stream.s == nil && (url.contains("&sig=") || url.contains("&lsig="))) {
                    os_log("signature found, skip decipher", log: log, type: .debug)
                    continue
                }
                
                if let cipheredSignature = stream.s {
                    // Remove the stream from `streamManifest` for now, as signature extraction currently doesn't work most of time
                    invalidStreamIndices.append(i)
                    continue // Skip the rest of the code as we are removing this stream
                    
                    let signature = try cipher.value.getSignature(cipheredSignature: cipheredSignature)
                    
                    os_log("finished descrambling signature for itag=%{public}i", log: log, type: .debug, stream.itag)
                    
                    guard var urlComponents = URLComponents(string: url) else { continue } // TODO: fail differently
                    
                    if urlComponents.queryItems == nil {
                        urlComponents.queryItems = []
                    }
                    urlComponents.queryItems?["sig"] = signature
                    
                    if urlComponents.queryItems?.contains(where: { $0.name == "ratebypass" }) ?? false {
                        let initialN = urlComponents.queryItems?["n"] ?? ""
                        let newN = try cipher.value.calculateN(initialN: Array(initialN))
                        urlComponents.queryItems?["n"] = newN
                    }
                    
                    let url = urlComponents.url?.absoluteString ?? url
                    
                    streamManifest[i].url = url
                }
            }
        }
        
        // Remove invalid streams
        for index in invalidStreamIndices.reversed() {
            streamManifest.remove(at: index)
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
