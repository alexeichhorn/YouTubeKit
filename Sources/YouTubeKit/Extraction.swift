//
//  Extraction.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation
import os.log

class Extraction {
    
    private static let log = OSLog(Extraction.self)
    
    class func extractVideoID(from url: String) -> String? {
        let regex = NSRegularExpression(#"(?:v=|\/)([0-9A-Za-z_-]{11}).*"#)
        return regex.firstMatch(in: url, group: 1)?.content
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
        var i = 1
        
        let contextClosers: [Character: Character] = [
            "{": "}",
            "[": "]",
            "\"": "\""
        ]
        
        while i < html.count {
            guard let currentContext = stack.last else {
                break
            }
            let currentChar = html[i]
            
            // current context gets closed
            if currentChar == contextClosers[currentContext] {
                _ = stack.popLast()
                i += 1
                continue
            }
            
            // strings require special context handling because they can contain context openers and closers
            if currentContext == "\"" {
                if currentChar == "\\" {
                    i += 2
                    continue
                }
            } else {
                // non-string contexts are when we need to look for context openers
                if contextClosers.keys.contains(currentChar) {
                    stack.append(currentChar)
                }
            }
            
            i += 1
        }
        
        let fullObject = html.substring(to: i)
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
            let liveStreamability: Bool?
            
            enum Status: String, Decodable {
                case ok = "OK"
                case unplayable = "UNPLAYABLE"
                case loginRequired = "LOGIN_REQUIRED"
                case error = "ERROR"
                case liveStream = "LIVE_STREAM"
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
    
}
