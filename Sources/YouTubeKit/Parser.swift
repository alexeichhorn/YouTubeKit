//
//  Parser.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 05.09.21.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
class Parser {
    
    /// Parses the throttling array into an array of strings.
    /// Expects input to begin with `[` and close with `]`.
    class func throttlingArraySplit(jsArray: String) throws -> [String] {
        var results = [String]()
        var currentSubstring = String(jsArray.dropFirst())
        
        let commaRegex = NSRegularExpression(#","#)
        let funcRegex = NSRegularExpression(#"function\([^)]*\)"#)
        
        while !currentSubstring.isEmpty {
            if currentSubstring.starts(with: "function") {
                // handle functions separately
                guard let match = funcRegex.firstMatch(in: currentSubstring) else {
                    throw YouTubeKitError.regexMatchError
                }
                
                let functionText = try Extraction.findObjectFromStartpoint(html: currentSubstring, startPoint: match.end)
                let fullFunctionDefinition = currentSubstring[..<currentSubstring.index(match.end, offsetBy: functionText.count)]
                results.append(String(fullFunctionDefinition))
                currentSubstring = String(currentSubstring[currentSubstring.index(after: fullFunctionDefinition.endIndex)...])
            } else {
                let matchStart: String.Index, matchEnd: String.Index
                if let match = commaRegex.firstMatch(in: currentSubstring) {
                    matchStart = match.start
                    matchEnd = match.end
                } else {
                    // capture end of array
                    matchStart = currentSubstring.index(before: currentSubstring.endIndex)
                    matchEnd = currentSubstring.endIndex
                }
                
                let currentEl = currentSubstring[..<matchStart]
                results.append(String(currentEl))
                currentSubstring = String(currentSubstring[matchEnd...])
            }
        }
        
        return results
    }
    
    
    // MARK: - Javascript Extraction
    
    class func findJavascriptFunctionFromStartpoint(html fullHTML: String, startPoint: String.Index) throws -> String {
        let html = String(fullHTML[startPoint...])
        guard ["{", "["].contains(html.first ?? " ") else {
            fatalError()
        }
        
        var stack = [html.first!]
        var regexStack: [Character] = []
        var i = html.index(after: html.startIndex)
        
        let contextClosers: [Character: Character] = [
            "{": "}",
            "[": "]",
            "\"": "\"",
            "'": "'",
            "/": "/"  // javascript regex
        ]
        
        // context inside regex
        let regexContextClosers: [Character: Character] = [
            "(": ")",
            "[": "]",
            "{": "}",
        ]
        
        var lastChar = html.first ?? " "
        
        let allowedCharactersBeforeRegex: Set<Character> =  ["(", ",", "=", ":", "[", "!", "&", "|", "?", "{", "}", ";", "\n"]
        
        let endIndex = html.endIndex
        while i < endIndex {
            guard let currentContext = stack.last else {
                break
            }
            let currentChar = html[i]
            
            defer {
                if currentChar != " " || lastChar != "\n" {
                    lastChar = currentChar
                }
            }
            
            // current context gets closed
            if currentContext == "/" && !regexStack.isEmpty {
                if let regexContext = regexStack.last, currentChar == regexContextClosers[regexContext] {
                    _ = regexStack.popLast()
                    i = html.index(after: i)
                    //print("regex closed '\(regexContext)'")
                    continue
                }
            } else {
                if currentChar == contextClosers[currentContext] {
                    _ = stack.popLast()
                    i = html.index(after: i)
                    //print("closed '\(currentContext)'")
                    continue
                }
            }
            
            // strings require special context handling because they can contain context openers and closers
            if currentContext == "\"" || currentContext == "'" || currentContext == "/" {
                if currentChar == "\\" {
                    i = html.index(i, offsetBy: 2)
                    continue
                }
                
                // regex special case
                if currentContext == "/" {
                    if regexContextClosers.keys.contains(currentChar) {
                        regexStack.append(currentChar)
                    }
                    i = html.index(after: i)
                    continue
                }
                
            } else {
                // non-string contexts are when we need to look for context openers
                if contextClosers.keys.contains(currentChar) {
                    if currentChar != "/" || allowedCharactersBeforeRegex.contains(lastChar) {
                        stack.append(currentChar)
                    }
                }
            }
            
            i = html.index(after: i)
        }
        
        let fullObject = String(html[..<i])
        return fullObject
    }
    
}
