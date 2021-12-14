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
    
}
