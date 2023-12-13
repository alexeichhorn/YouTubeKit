//
//  Foundation.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation

extension String {
    
    private func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    subscript(_ position: Int) -> Character {
        let index = index(from: position)
        return self[index]
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with range: Range<Int>) -> String {
        let startIndex = index(from: range.lowerBound)
        let endIndex = index(from: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    
    func strip(from unwantedCharacters: String) -> String {
        var result = self
        for unwantedCharacter in unwantedCharacters {
            result = result.replacingOccurrences(of: String(unwantedCharacter), with: "")
        }
        return result
    }
    
    
    // - MARK: Escaping
    
    func unescaped() -> String {
        
        let escapedChars = [
            (#"\0"#, "\0"),
            (#"\t"#, "\t"),
            (#"\n"#, "\n"),
            (#"\r"#, "\r"),
            (#"\""#, "\""),
            (#"\'"#, "\'"),
            (#"\\"#, "\\")
        ]
        
        var result: String = self
        escapedChars.forEach {
            result = result.replacingOccurrences(of: $0.0, with: $0.1)
        }
        return result
    }
    
}

extension Collection {
    
    /// - returns: element where calculated property is maximum
    func max<T: Comparable>(byProperty property: (Element) throws -> T) rethrows -> Element? {
        let mapped = try map({ ($0, try property($0)) })
        return mapped.max(by: { $0.1 < $1.1 })?.0
    }
    
    /// - returns: element where parameter given in `keyPath` is maximum
    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
        let mapped = map { ($0, $0[keyPath: keyPath]) }
        return mapped.max(by: { $0.1 < $1.1 })?.0
    }
    
    /// - returns: element where calculated property is minimum
    func min<T: Comparable>(byProperty property: (Element) throws -> T) rethrows -> Element? {
        let mapped = try map({ ($0, try property($0)) })
        return mapped.min(by: { $0.1 < $1.1 })?.0
    }
    
    /// - returns: element where parameter given in `keyPath` is minimum
    func min<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
        let mapped = map { ($0, $0[keyPath: keyPath]) }
        return mapped.min(by: { $0.1 < $1.1 })?.0
    }
    
}

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}

extension Collection where Element: Hashable {
    
    var identityDictionary: [Element: Element] {
        var result = [Element: Element]()
        for element in self {
            result[element] = element
        }
        return result
    }
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        var seen = Set<Element>()
        for element in self {
            if seen.insert(element).inserted {
                result.append(element)
            }
        }
        return result
    }
    
}

extension Dictionary {
    
    mutating func merge(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    
    func merging(with dict: [Key: Value]) -> Self {
        var result = self
        result.merge(dict: dict)
        return result
    }
    
}

extension Array where Element == URLQueryItem {
    
    subscript(_ key: String) -> String? {
        get {
            first(where: { $0.name == key })?.value
        }
        set {
            if let index = firstIndex(where: { $0.name == key }) {
                self[index].value = newValue
            } else {
                self.append(URLQueryItem(name: key, value: newValue))
            }
        }
    }
    
}
