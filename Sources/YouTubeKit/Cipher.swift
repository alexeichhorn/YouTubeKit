//
//  Cipher.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 05.09.21.
//

import Foundation
#if canImport(JavaScriptCore)
import JavaScriptCore
#endif
import os.log

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
class Cipher {
    
    let js: String
    
    private let transformPlan: [(func: JSFunction, param: Int)]
    private let transformMap: [String: JSFunction]
    
    private let jsFuncPatterns =  [
        NSRegularExpression(#"\w+\.(\w+)\(\w,(\d+)\)"#),
        NSRegularExpression(#"\w+\[(\"\w+\")\]\(\w,(\d+)\)"#)
    ]
    
    private let nParameterFunction: String
    
    private var calculatedN = [String: String]()
    
    private static let log = OSLog(Cipher.self)
    
    init(js: String) throws {
        self.js = js
        
        let rawTransformPlan = try Cipher.getRawTransformPlan(js: js)

        let varRegex = NSRegularExpression(#"^\$*\w+\W"#)
        guard let varMatch = varRegex.firstMatch(in: rawTransformPlan[0], group: 0) else {
            throw YouTubeKitError.regexMatchError
        }
        var variable = varMatch.content
        _ = variable.popLast()
        
        self.transformMap = try Cipher.getTransformMap(js: js, variable: variable)
        self.transformPlan = try Cipher.getDecodedTransformPlan(rawPlan: rawTransformPlan, variable: variable, transformMap: transformMap)
        
        self.nParameterFunction = try Cipher.getThrottlingFunctionCode(js: js) //try Cipher.getNParameterFunction(js: js)
    }
    
    /// Converts n to the correct value to prevent throttling.
    func calculateN(initialN: String) throws -> String {
        if let newN = calculatedN[initialN] {
            return newN
        }
        
#if canImport(JavaScriptCore)
        guard let context = JSContext() else {
            os_log("failed to create JSContext", log: Cipher.log, type: .error)
            return ""
        }
        
        context.evaluateScript(nParameterFunction)
        
        let function = context.objectForKeyedSubscript("processNSignature")
        let result = function?.call(withArguments: [initialN])
        
        guard let result, result.isString, let newN = result.toString() else {
            os_log("failed to calculate n", log: Cipher.log, type: .error)
            return ""
        }
        
        // cache the result
        calculatedN[initialN] = newN
        
        return newN
#else
        return ""
#endif
    }
    
    /// Decipher the signature
    func getSignature(cipheredSignature: String) -> String? {
        var signature = Array(cipheredSignature)
        
        guard !transformPlan.isEmpty else {
            return nil
        }
        
        // apply transform functions
        for (function, param) in transformPlan {
            switch function {
            case .reverse:
                signature.reverse()
            case .splice:
                signature = Array(signature.dropFirst(param))
            case .swap:
                (signature[0], signature[param % signature.count]) = (signature[param % signature.count], signature[0])
            }
        }
        
        return String(signature)
    }
    
    
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
    class func getRawTransformPlan(js: String) throws -> [String] {
        let name = try getInitialFunctionName(js: js)
        let pattern = NSRegularExpression(NSRegularExpression.escapedPattern(for: name) + #"=function\(\w\)\{[a-z=\.\(\"\)]*;(.*);(?:.+)\}"#)
        os_log("getting transform plan", log: log, type: .debug)
        if let match = pattern.firstMatch(in: js, group: 1) {
            return match.content.components(separatedBy: ";")
        }
        throw YouTubeKitError.regexMatchError
    }
    
    /// Transforms raw transform plan in to a decoded transform plan with functions and parameters
    /// - Note: returns empty array if transformation failed
    class func getDecodedTransformPlan(rawPlan: [String], variable: String, transformMap: [String: JSFunction]) throws -> [(func: JSFunction, param: Int)] {
        let pattern = try NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: variable) + #"\.(.+)\(.+,(\d+)\)"#) // expecting e.g. "wP.Nl(a,65)"
        
        var result: [(func: JSFunction, param: Int)] = []
        
        for functionCall in rawPlan {
            guard let (_, matchGroups) = pattern.allMatches(in: functionCall, includingGroups: [1, 2]).first,
                  let functionName = matchGroups[1]?.content,
                  let parameter = matchGroups[2]?.content
            else {
                os_log("failed to decode function call %{public}@", log: log, type: .error, functionCall)
                return []
            }
            
            guard let decodedParameter = Int(parameter) else { return [] }
            guard let function = transformMap[functionName] else {
                os_log("failed to find function %{public}@", log: log, type: .error, functionName)
                return []
            }
            
            result.append((func: function, param: decodedParameter))
        }
        return result
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
    class func getThrottlingFunctionCode(js: String, functionName: String = "processNSignature") throws -> String {
        let name = try getThrottlingFunctionName(js: js)
        
        let regex = NSRegularExpression(NSRegularExpression.escapedPattern(for: name) + #"=function\((\w)\)"#)
        guard let (match, groupMatches) = regex.firstMatch(in: js, includingGroups: [1]) else {
            throw YouTubeKitError.regexMatchError
        }
        
        guard let variableName = groupMatches[1]?.content else {
            throw YouTubeKitError.regexMatchError
        }
        
        let code = try Parser.findJavascriptFunctionFromStartpoint(html: js, startPoint: match.end)
        
        return "function \(functionName)(\(variableName)) \(code)"
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
    
    
    // MARK: - n parameter function
    
    private class func getNParameterFunction(js: String) throws -> String {
        
        //let pattern = NSRegularExpression(#"\.get\("n"\)\)&&\(b=(?P<nfunc>[a-zA-Z0-9$]+)(?:\[(?P<idx>\d+)\])?\([a-zA-Z0-9]\)"#)
        
        let parts = js.replacingOccurrences(of: "\n", with: "").components(separatedBy: "var b=a.split(\"\")")
        
        guard parts.count > 1 else {
            return ""
        }
        
        return #"function processNSignature(a) { var b=a.split("")"# + parts[1].components(separatedBy: #"return b.join("")"#)[0] + #";return b.join(""); }"#
    }
    
}
