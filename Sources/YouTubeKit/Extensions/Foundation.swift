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
