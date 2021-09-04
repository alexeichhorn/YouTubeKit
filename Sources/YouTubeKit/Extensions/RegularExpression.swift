//
//  RegularExpression.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation

extension NSRegularExpression {
    
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression \(pattern)")
        }
    }
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
    
    
    /*struct Match {
        let content: String
        let start: Int
        let end: Int
    }
    
    func firstMatch(in string: String, group: Int? = nil) -> Match? {
        let range = NSRange(location: 0, length: string.utf16.count)
        let result = firstMatch(in: string, options: [], range: range)
        let resultRange = group.flatMap { result?.range(at: $0) } ?? result?.range
        return resultRange.map { Match(content: string.substring(with: Range<Int>($0)!), start: $0.lowerBound, end: $0.upperBound) }
    }
    
    func allMatches(in string: String) -> [Match] {
        let range = NSRange(location: 0, length: string.utf16.count)
        let results = matches(in: string, options: [], range: range)
        return results.map { Match(content: string.substring(with: Range<Int>($0.range)!), start: $0.range.lowerBound, end: $0.range.upperBound) }
    }*/
    
    struct Match {
        let content: String
        let start: String.Index
        let end: String.Index
    }
    
    func firstMatch(in string: String, group: Int? = nil) -> Match? {
        let range = NSRange(location: 0, length: string.utf16.count)
        let result = firstMatch(in: string, options: [], range: range)
        let resultRange = group.flatMap { result?.range(at: $0) } ?? result?.range
        let s = resultRange.flatMap { Range($0, in: string) }.map { string[$0] }
        return resultRange.flatMap { Range($0, in: string) }.map { Match(content: String(string[$0]), start: $0.lowerBound, end: $0.upperBound) }
    }
    
    func allMatches(in string: String) -> [Match] {
        let range = NSRange(location: 0, length: string.utf16.count)
        let results = matches(in: string, options: [], range: range)
        let resultRanges = results.compactMap { Range($0.range, in: string) }
        return resultRanges.map { Match(content: String(string[$0]), start: $0.lowerBound, end: $0.upperBound) }
    }
    
}
