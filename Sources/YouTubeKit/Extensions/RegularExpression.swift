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
    
    
    struct Match {
        let content: String
        let start: String.Index
        let end: String.Index
    }
    
    func firstMatch(in string: String, group: Int? = nil) -> Match? {
        let range = NSRange(location: 0, length: string.utf16.count)
        let result = firstMatch(in: string, options: [], range: range)
        let resultRange = group.flatMap { result?.range(at: $0) } ?? result?.range
        return resultRange.flatMap { Range($0, in: string) }.map { Match(content: String(string[$0]), start: $0.lowerBound, end: $0.upperBound) }
    }
    
    func firstMatch(in string: String, includingGroups groups: [Int]) -> (Match, [Int: Match])? {
        let range = NSRange(location: 0, length: string.utf16.count)
        guard let result = firstMatch(in: string, options: [], range: range),
              let mainRange = Range(result.range, in: string) else {
            return nil
        }
        
        let groupRanges = groups.identityDictionary
            .filter { $0.key < result.numberOfRanges }
            .compactMapValues { Range(result.range(at: $0), in: string) }
        
        guard groupRanges.count == groups.count else {
            return nil
        }
        
        let mainMatch = Match(content: String(string[mainRange]), start: mainRange.lowerBound, end: mainRange.upperBound)
        let groupMatches = groupRanges.mapValues { range in
            Match(content: String(string[range]), start: range.lowerBound, end: range.upperBound)
        }
        
        return (mainMatch, groupMatches)
    }
    
    func allMatches(in string: String) -> [Match] {
        let range = NSRange(location: 0, length: string.utf16.count)
        let results = matches(in: string, options: [], range: range)
        let resultRanges = results.compactMap { Range($0.range, in: string) }
        return resultRanges.map { Match(content: String(string[$0]), start: $0.lowerBound, end: $0.upperBound) }
    }
    
    func allMatches(in string: String, includingGroups groups: [Int]) -> [(Match, [Int: Match])] {
        let range = NSRange(location: 0, length: string.utf16.count)
        let results = matches(in: string, options: [], range: range)
        let resultRanges = results.compactMap { result -> (Range<String.Index>?, [Int: Range<String.Index>?]) in
            let groupRanges = groups.identityDictionary.filter { $0.key < result.numberOfRanges }.mapValues { result.range(at: $0) }.mapValues { Range($0, in: string) }
            return (Range(result.range, in: string), groupRanges)
        }
        let compactedResultRanges = resultRanges.compactMap { mainRange, groupRanges -> (Range<String.Index>, [Int: Range<String.Index>])? in
            if let mainRange = mainRange, !groupRanges.contains(where: { $0.value == nil }) {
                return (mainRange, groupRanges.mapValues { $0! })
            }
            return nil
        }
        return compactedResultRanges.map { mainRange, groupRanges in
            let groupMatches = groupRanges.mapValues {
                Match(content: String(string[$0]), start: $0.lowerBound, end: $0.upperBound)
            }
            return (Match(content: String(string[mainRange]), start: mainRange.lowerBound, end: mainRange.upperBound), groupMatches)
        }
    }
    
}

extension String {
    
    mutating func replace(_ pattern: NSRegularExpression, with replacement: String) {
        let range = NSRange(location: 0, length: utf16.count)
        self = pattern.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
    
}
