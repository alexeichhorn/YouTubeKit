//
//  Cipher.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 05.09.21.
//

import Foundation
import os.log

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
class Cipher {
    
    let js: String
    
    private let transformPlan: [String]
    private let transformMap: [String: JSFunction]
    
    private let jsFuncPatterns =  [
        NSRegularExpression(#"\w+\.(\w+)\(\w,(\d+)\)"#),
        NSRegularExpression(#"\w+\[(\"\w+\")\]\(\w,(\d+)\)"#)
    ]
    
    private let throttlingPlan: [(String, String, String?)]
    private let throttlingArray: [ThrottlingJSExpression]
    
    private var calculatedN: String?
    
    private static let log = OSLog(Cipher.self)
    
    init(js: String) throws {
        self.js = js
        self.transformPlan = try Cipher.getTransformPlan(js: js)

        let varRegex = NSRegularExpression(#"^\$*\w+\W"#)
        guard let varMatch = varRegex.firstMatch(in: transformPlan[0], group: 0) else {
            throw YouTubeKitError.regexMatchError
        }
        var variable = varMatch.content
        _ = variable.popLast()
        
        self.transformMap = try Cipher.getTransformMap(js: js, variable: variable)
        
        self.throttlingPlan = try Cipher.getThrottlingPlan(js: js)
        self.throttlingArray = try Cipher.getThrottlingFunctionArray(js: js)
    }
    
    // TODO: set correct result type
    /// Converts n to the correct value to prevent throttling.
    func calculateN(initialN: [Character]) throws -> String {
        if let calculatedN = calculatedN {
            return calculatedN
        }
        
        return "" // TODO: implement
        
        /*for i in 0..<throttlingArray.count {
            if case .stringValue("b") = throttlingArray[i] {
                throttlingArray[i] = initialN
            }
        }
        
        for step in throttlingPlan {
            let currentFunction = throttlingArray[Int(step.0) ?? 0]
            
            guard currentFunction.isCallable else {
                os_log("Function at %i is not callable. Throttling array: %@", step.0, throttlingArray)
                throw YouTubeKitError.extractError
            }
            
            let firstArgument = throttlingArray[Int(step.1) ?? 0]
            
            if let thirdStep = step.2 {
                let secondArgument = throttlingArray[Int(thirdStep) ?? 0]
                currentFunction.execute(on: firstArgument, and: secondArgument)
            } else {
                currentFunction.execute(on: firstArgument)
            }
        }
        
        calculatedN = initialN.lazy.joined()
        return calculatedN!*/
    }
    
    /// Decipher the signature
    func getSignature(cipheredSignature: String) -> String {
        var signature = Array(cipheredSignature)
        
        // TODO: apply transform functions
        
        return String(signature)
    }
    
    /// Parse the Javascript transform function.
    /// Break a JavaScript transform function down into a two element tuple containing the function name and some integer-based argument.
    /*func parseFunction(jsFunction: String) -> (String, Int) {
        for pattern in jsFuncPatterns {
            if let parseMatch = pattern.firstMatch(in: jsFunction, group: <#T##Int?#>)
        }
    }*/
    
    
    // MARK: - Static Functions
    
    /// Extract the name of the function responsible for computing the signature.
    class func getInitialFunctionName(js: String) throws -> String {
        // note: make sure patterns don't contain named groups. Instead the function name should be always in group 1
        let functionPatterns = [
            #"\b[cs]\s*&&\s*[adf]\.set\([^,]+\s*,\s*encodeURIComponent\s*\(\s*([a-zA-Z0-9$]+)\("#,
            #"\b[a-zA-Z0-9]+\s*&&\s*[a-zA-Z0-9]+\.set\([^,]+\s*,\s*encodeURIComponent\s*\(\s*([a-zA-Z0-9$]+)\("#,
            #"(?:\b|[^a-zA-Z0-9$])([a-zA-Z0-9$]{2})\s*=\s*function\(\s*a\s*\)\s*\{\s*a\s*=\s*a\.split\(\s*\"\"\s*\)"#,  // slight modifications from original
            #"([a-zA-Z0-9$]+)\s*=\s*function\(\s*a\s*\)\s*\{\s*a\s*=\s*a\.split\(\s*""\s*\)"#,  // escaped {
            #"["\']signature["\']\s*,\s*([a-zA-Z0-9$]+)\("#, // slightly modified (weaker condition) to correctly have function name in group 1
            #"\.sig\|\|([a-zA-Z0-9$]+)\("#,
            #"yt\.akamaized\.net/\)\s*\|\|\s*.*?\s*[cs]\s*&&\s*[adf]\.set\([^,]+\s*,\s*(?:encodeURIComponent\s*\()?\s*([a-zA-Z0-9$]+)\("#,  // noqa: E501
            #"\b[cs]\s*&&\s*[adf]\.set\([^,]+\s*,\s*([a-zA-Z0-9$]+)\("#,  // noqa: E501
            #"\b[a-zA-Z0-9]+\s*&&\s*[a-zA-Z0-9]+\.set\([^,]+\s*,\s*([a-zA-Z0-9$]+)\("#,  // noqa: E501
            #"\bc\s*&&\s*a\.set\([^,]+\s*,\s*\([^)]*\)\s*\(\s*([a-zA-Z0-9$]+)\("#,  // noqa: E501
            #"\bc\s*&&\s*[a-zA-Z0-9]+\.set\([^,]+\s*,\s*\([^)]*\)\s*\(\s*([a-zA-Z0-9$]+)\("#,  // noqa: E501
            #"\bc\s*&&\s*[a-zA-Z0-9]+\.set\([^,]+\s*,\s*\([^)]*\)\s*\(\s*([a-zA-Z0-9$]+)\("#,  // noqa: E501
        ].map { NSRegularExpression($0) }
        os_log("finding initial function name", log: log, type: .debug)
        
        for pattern in functionPatterns {
            if let functionMatch = pattern.firstMatch(in: js, group: 1) {
                os_log("finished regex search, matched %{public}@", log: log, type: .debug, pattern.pattern)
                return functionMatch.content
            }
        }
        
        throw YouTubeKitError.regexMatchError
    }
    
    /// Extract the "transform plan".
    /// The "transform plan" is the functions that the ciphered signature is cycled through to obtain the actual signature.
    class func getTransformPlan(js: String) throws -> [String] {
        let name = try getInitialFunctionName(js: js)
        let pattern = NSRegularExpression(NSRegularExpression.escapedPattern(for: name) + #"=function\(\w\)\{[a-z=\.\(\"\)]*;(.*);(?:.+)\}"#)
        os_log("getting transform plan", log: log, type: .debug)
        if let match = pattern.firstMatch(in: js, group: 1) {
            return match.content.components(separatedBy: ";")
        }
        throw YouTubeKitError.regexMatchError
    }
    
    /// Extract the "transform object".
    /// The "transform object" contains the function definitions referenced in the transform plan". The ``variable`` argument is the obfuscated variable name
    /// which contains these functions, for example, given the function call ``DE.AJ(a,15)`` returned by the transform plan, "DE" would be the var.
    class func getTransformObject(js: String, variable: String) throws -> [String] {
        let pattern = try! NSRegularExpression(pattern: #"var "# + NSRegularExpression.escapedPattern(for: variable) + #"=\{(.*?)\};"#, options: [.dotMatchesLineSeparators])
        os_log("getting transform object", log: log, type: .debug)

        if let transformMatch = pattern.firstMatch(in: js, group: 1) {
            return transformMatch.content.replacingOccurrences(of: "\n", with: " ").components(separatedBy: ", ")
        }
        throw YouTubeKitError.regexMatchError
    }
    
    /// Build a transform function lookup.
    /// Build a lookup table of obfuscated JavaScript function names to the Swift equivalents.
    class func getTransformMap(js: String, variable: String) throws -> [String: JSFunction] {
        let transformObject = try getTransformObject(js: js, variable: variable)
        var mapper = [String: JSFunction]()
        
        for object in transformObject {
            let components = object.split(separator: ":", maxSplits: 1)
            let name = String(components.first ?? "")
            let function = String(components[safe: 1] ?? "")
            let fn = try mapFunctions(jsFunction: function)
            mapper[name] = fn
        }
        return mapper
    }
    
    /// Extract the name of the function that computes the throttling parameter.
    class func getThrottlingFunctionName(js: String) throws -> String {
        let functionPatterns = [
            NSRegularExpression(#"a\.[a-zA-Z]\s*&&\s*\([a-z]\s*=\s*a\.get\("n"\)\)\s*&&\s*"#),
            NSRegularExpression(#"\([a-z]\s*=\s*([a-zA-Z0-9$]+)(\[\d+\])?\([a-z]\)"#)
        ]
        for pattern in functionPatterns {
            guard let (_, functionMatchGroups) = pattern.allMatches(in: js, includingGroups: [1, 2]).first else { continue }
            guard let firstGroup = functionMatchGroups[1] else { continue }
            guard let secondGroup = functionMatchGroups[2] else {
                return firstGroup.content
            }
            
            guard let index = Int(secondGroup.content.strip(from: "[]")) else { continue }
            let arrayPattern = NSRegularExpression(#"var "# + NSRegularExpression.escapedPattern(for: firstGroup.content) + #"\s*=\s*(\[.+?\]);"#)
            if let arrayMatch = arrayPattern.firstMatch(in: js, group: 1) {
                let array = arrayMatch.content.strip(from: "[]").split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                if array.indices.contains(index) {
                    return array[index]
                }
            }
        }
        
        throw YouTubeKitError.regexMatchError
    }
    
    /// Extract the raw code for the throttling function.
    class func getThrottlingFunctionCode(js: String) throws -> String {
        let name = try getThrottlingFunctionName(js: js)
        
        let regex = NSRegularExpression(NSRegularExpression.escapedPattern(for: name) + #"=function\(\w\)"#)
        guard let match = regex.firstMatch(in: js) else {
            throw YouTubeKitError.regexMatchError
        }
        
        // TODO: not yet implemented like in pytube
        
        return String(js[match.start...])
    }
    
    enum ThrottlingJSExpression {
        case unshift
        case reverse
        case push
        case swap
        case cipherFunction
        case nestedSplice
        case splice
        case prepend
        case intValue(Int)
        case stringValue(String)
        case array([ThrottlingJSExpression?])
        
        var isCallable: Bool {
            switch self {
            case .array(_), .stringValue(_), .intValue(_): return false
            default: return true
            }
        }
        
        func execute(on argument: ThrottlingJSExpression, and secondArgument: ThrottlingJSExpression? = nil) {
            
        }
    }
    
    /// Extract the "c" array.
    class func getThrottlingFunctionArray(js: String) throws -> [ThrottlingJSExpression] {
        let rawCode = try getThrottlingFunctionCode(js: js)
        
        let arrayRegex = NSRegularExpression(#",c=\["#)
        guard let match = arrayRegex.firstMatch(in: rawCode) else {
            throw YouTubeKitError.regexMatchError
        }
        
        let arrayRaw = try Extraction.findObjectFromStartpoint(html: rawCode, startPoint: rawCode.index(before: match.end))
        let strArray = try Parser.throttlingArraySplit(jsArray: arrayRaw)
        
        var convertedArray = [ThrottlingJSExpression?]()
        for el in strArray {
            if let intValue = Int(el) {
                convertedArray.append(.intValue(intValue))
            }
            
            if el == "null" {
                convertedArray.append(nil)
                continue
            }
            
            if el.starts(with: "\"") && el.hasSuffix("\"") { // remove quotation marks
                convertedArray.append(.stringValue(String(el.dropFirst().dropLast())))
                continue
            }
            
            if el.starts(with: "function") {
                let mapper = [
                    (NSRegularExpression(#"\{for\(\w=\(\w%\w\.length\+\w\.length\)%\w\.length;\w--;\)\w\.unshift\(\w.pop\(\)\)\}"#), ThrottlingJSExpression.unshift),
                    (NSRegularExpression(#"\{\w\.reverse\(\)\}"#), .reverse),
                    (NSRegularExpression(#"\{\w\.push\(\w\)\}"#), .push),
                    (NSRegularExpression(#";var\s\w=\w\[0\];\w\[0\]=\w\[\w\];\w\[\w\]=\w\}"#), .swap),
                    (NSRegularExpression(#"case\s\d+"#), .cipherFunction),
                    (NSRegularExpression(#"\w\.splice\(0,1,\w\.splice\(\w,1,\w\[0\]\)\[0\]\)"#), .nestedSplice),
                    (NSRegularExpression(#";\w\.splice\(\w,1\)\}"#), .splice),
                    (NSRegularExpression(#"\w\.splice\(-\w\)\.reverse\(\)\.forEach\(function\(\w\)\{\w\.unshift\(\w\)\}\)"#), .prepend),
                    (NSRegularExpression(#"for\(var \w=\w\.length;\w;\)\w\.push\(\w\.splice\(--\w,1\)\[0\]\)\}"#), .reverse)
                ]
                
                var found = false
                for (pattern, fn) in mapper {
                    if pattern.matches(el) {
                        convertedArray.append(fn)
                        found = true
                    }
                }
                
                if found {
                    continue
                }
            }
            
            convertedArray.append(.stringValue(el))
        }
        
        // replace null elements with array itself
        for i in 0..<convertedArray.count {
            if convertedArray[i] == nil {
                convertedArray[i] = .array(convertedArray)
            }
        }
        
        return convertedArray.compactMap { $0 }
    }
    
    /// The "throttling plan" is a list of tuples used for calling functions in the c array. The first element of the tuple is the index of the
    // function to call, and any remaining elements of the tuple are arguments to pass to that function.
    class func getThrottlingPlan(js: String) throws -> [(String, String, String?)] {
        let rawCode = try getThrottlingFunctionCode(js: js)
        
        let planRegex = NSRegularExpression(#"try\{"#)
        guard let match = planRegex.firstMatch(in: rawCode) else {
            throw YouTubeKitError.regexMatchError
        }
        
        let transformPlanRaw = try Extraction.findObjectFromStartpoint(html: rawCode, startPoint: rawCode.index(before: match.end))
        
        let stepRegex = NSRegularExpression(#"c\[(\d+)\]\(c\[(\d+)\](,c(\[(\d+)\]))?\)"#)
        let matches = stepRegex.allMatches(in: transformPlanRaw, includingGroups: [0, 1, 4])
        var transformSteps = [(String, String, String?)]()
        
        for (_, groupMatches) in matches {
            if groupMatches[4]?.content != "" {
                transformSteps.append((groupMatches[0]!.content, groupMatches[1]!.content, groupMatches[4]?.content))
            } else {
                transformSteps.append((groupMatches[0]!.content, groupMatches[1]!.content, nil))
            }
        }
        return transformSteps
    }
    
    enum JSFunction {
        case reverse
        case splice
        case swap
    }
    
    /// For a given JavaScript transform function, return the `JSFunction` equivalent.
    class func mapFunctions(jsFunction: String) throws -> JSFunction {
        let mapper = [
            // function(a){a.reverse()}
            (NSRegularExpression(#"\{\w\.reverse\(\)\}"#), JSFunction.reverse),
            // function(a,b){a.splice(0,b)}
            (NSRegularExpression(#"\{\w\.splice\(0,\w\)\}"#), .splice),
            // function(a,b){var c=a[0];a[0]=a[b%a.length];a[b]=c}
            (NSRegularExpression(#"\{var\s\w=\w\[0\];\w\[0\]=\w\[\w\%\w.length\];\w\[\w\]=\w\}"#), .swap),
            // function(a,b){var c=a[0];a[0]=a[b%a.length];a[b%a.length]=c}
            (NSRegularExpression(#"\{var\s\w=\w\[0\];\w\[0\]=\w\[\w\%\w.length\];\w\[\w\%\w.length\]=\w\}"#), .swap)
        ]
        
        for (pattern, fn) in mapper {
            if pattern.matches(jsFunction) {
                return fn
            }
        }
        
        throw YouTubeKitError.regexMatchError
    }
    
}
