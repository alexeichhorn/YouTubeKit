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
        
        /*let rawTransformPlan = try Cipher.getRawTransformPlan(js: js)

        let varRegex = NSRegularExpression(#"^\$*\w+\W"#)
        guard let varMatch = varRegex.firstMatch(in: rawTransformPlan[0], group: 0) else {
            throw YouTubeKitError.regexMatchError
        }
        var variable = varMatch.content
        _ = variable.popLast()
        
        self.transformMap = try Cipher.getTransformMap(js: js, variable: variable)
        self.transformPlan = try Cipher.getDecodedTransformPlan(rawPlan: rawTransformPlan, variable: variable, transformMap: transformMap)*/
        // -> temporarily disabled (as mostly unused)
        self.transformMap = [:]
        self.transformPlan = []
        
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

        struct ExtractionRegex {
            let regex: NSRegularExpression
            let group: Int

            init(pattern: String, group: Int) {
                self.regex = NSRegularExpression(pattern)
                self.group = group
            }

            func firstMatch(in js: String) -> NSRegularExpression.Match? {
                return regex.firstMatch(in: js, group: group)
            }
        }

        // note: make sure patterns don't contain named groups. Instead the function name should be always in group 1
        let functionPatterns = [
            ExtractionRegex(pattern: #"\b([a-zA-Z0-9_$]+)&&\(\1=([a-zA-Z0-9_$]{2,})\(decodeURIComponent\(\1\)\)"#, group: 2),
            ExtractionRegex(pattern: #"([a-zA-Z0-9_$]+)\s*=\s*function\(\s*([a-zA-Z0-9_$]+)\s*\)\s*\{\s*\2\s*=\s*\2\.split\(\s*\"\"\s*\)\s*;\s*[^}]+;\s*return\s+\2\.join\(\s*\"\"\s*\)"#, group: 1),
            ExtractionRegex(pattern: #"(?:\b|[^a-zA-Z0-9_$])([a-zA-Z0-9_$]{2,})\s*=\s*function\(\s*a\s*\)\s*\{\s*a\s*=\s*a\.split\(\s*\"\"\s*\)(?:;[a-zA-Z0-9_$]{2}\.[a-zA-Z0-9_$]{2}\(a,\d+\))?"#, group: 1),
            // older
            ExtractionRegex(pattern: #"\b[cs]\s*&&\s*[adf]\.set\([^,]+\s*,\s*encodeURIComponent\s*\(\s*([a-zA-Z0-9$]+)\("#, group: 1),
            ExtractionRegex(pattern: #"\b[a-zA-Z0-9]+\s*&&\s*[a-zA-Z0-9]+\.set\([^,]+\s*,\s*encodeURIComponent\s*\(\s*([a-zA-Z0-9$]+)\("#, group: 1),
            ExtractionRegex(pattern: #"(?:\b|[^a-zA-Z0-9$])([a-zA-Z0-9$]{2})\s*=\s*function\(\s*a\s*\)\s*\{\s*a\s*=\s*a\.split\(\s*""\s*\)"#, group: 1),  // slight modifications from original
            ExtractionRegex(pattern: #"([a-zA-Z0-9$]+)\s*=\s*function\(\s*a\s*\)\s*\{\s*a\s*=\s*a\.split\(\s*""\s*\)"#, group: 1),  // escaped {
            ExtractionRegex(pattern: #"["\']signature["\']\s*,\s*([a-zA-Z0-9$]+)\("#, group: 1), // slightly modified (weaker condition) to correctly have function name in group 1
            ExtractionRegex(pattern: #"\.sig\|\|([a-zA-Z0-9$]+)\("#, group: 1),
            ExtractionRegex(pattern: #"yt\.akamaized\.net/\)\s*\|\|\s*.*?\s*[cs]\s*&&\s*[adf]\.set\([^,]+\s*,\s*(?:encodeURIComponent\s*\()?\s*([a-zA-Z0-9$]+)\("#, group: 1),
            ExtractionRegex(pattern: #"\b[cs]\s*&&\s*[adf]\.set\([^,]+\s*,\s*([a-zA-Z0-9$]+)\("#, group: 1),
            ExtractionRegex(pattern: #"\b[a-zA-Z0-9]+\s*&&\s*[a-zA-Z0-9]+\.set\([^,]+\s*,\s*([a-zA-Z0-9$]+)\("#, group: 1),
            ExtractionRegex(pattern: #"\bc\s*&&\s*a\.set\([^,]+\s*,\s*\([^)]*\)\s*\(\s*([a-zA-Z0-9$]+)\("#, group: 1),
            ExtractionRegex(pattern: #"\bc\s*&&\s*[a-zA-Z0-9]+\.set\([^,]+\s*,\s*\([^)]*\)\s*\(\s*([a-zA-Z0-9$]+)\("#, group: 1),
        ]
        os_log("finding initial function name", log: log, type: .debug)
        
        for pattern in functionPatterns {
            if let functionMatch = pattern.firstMatch(in: js) {
                os_log("finished regex search, matched %{public}@", log: log, type: .debug, pattern.regex.pattern)
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
    class private func getThrottlingFunctionName(js: String, globalVar: PlayerGlobalVar?) throws -> String {
        
        let functionName: String
        let index: Int?
        
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            
            if let globalVar {
                if let debugStringIndex = globalVar.globalList.firstIndex(where: { $0.hasSuffix("-_w8_") }) {
                    
                    let pattern = #"""
                    (?x)
                    \{\s*return\s+{{varname}}\[{{index}}\]\s*\+\s*(?P<argname>[a-zA-Z0-9_$]+)\s*\}
                    """#.replacingOccurrences(of: "{{varname}}", with: globalVar.name).replacingOccurrences(of: "{{index}}", with: "\(debugStringIndex)")
                    
                    if let match = try Regex(pattern).firstMatch(in: js) {
                        let argname = match.output["argname"]?.substring ?? ""
                        let innerReversedContent = js[..<match.range.lowerBound].reversed()
                        
                        let pattern = #"""
                        (?x)
                        \{\s*\){{argname}}\(\s*
                        (?:
                            (?P<funcname_a>[a-zA-Z0-9_$]+)\s*noitcnuf\s*
                            |noitcnuf\s*=\s*(?P<funcname_b>[a-zA-Z0-9_$]+)(?:\s+rav)?
                        )[;\n]
                        """#.replacingOccurrences(of: "{{argname}}", with: String(argname.reversed()))
                        
                        if let match = try Regex(pattern).firstMatch(in: String(innerReversedContent)) {
                            let a = match.output["funcname_a"]?.substring
                            let b = match.output["funcname_b"]?.substring
                            if let funcname = a ?? b {
                                return String(funcname.reversed())
                            }
                        }
                    }
                }
            }
            
            
            
            
            /*
             Full regex pattern:
             """
             (?x)
             (?:
                 \.get\("n"\)\)&&\(b=|
                 (?:
                     b=String\.fromCharCode\(110\)|
                     (?P<str_idx>[a-zA-Z0-9_$.]+)&&\(b="nn"\[\+(?P=str_idx)\]
                 )
                 (?:
                     ,[a-zA-Z0-9_$]+\(a\))?,c=a\.
                     (?:
                         get\(b\)|
                         [a-zA-Z0-9_$]+\[b\]\|\|null
                     )\)&&\(c=|
                 \b(?P<var>[a-zA-Z0-9_$]+)=
             )(?P<nfunc>[a-zA-Z0-9_$]+)(?:\[(?P<idx>\d+)\])?\([a-zA-Z]\)
             (?(var),[a-zA-Z0-9_$]+\.set\((?:"n+"|[a-zA-Z0-9_$]+)\,(?P=var)\))
             """
             
             -> We split it up in two, as Swift can't handle the conditional (on the last line). So we handle it in code
             */
            
            let patternWithVar = #/
            (?x)
            (?:
                \b(?P<var>[a-zA-Z0-9_$]+)=
            )(?P<nfunc>[a-zA-Z0-9_$]+)(?:\[(?P<idx>\d+)\])?\([a-zA-Z]\)
            (,[a-zA-Z0-9_$]+\.set\((?:"n+"|[a-zA-Z0-9_$]+)\,(?P=var)\))
            /#
            
            let patternWithoutVar = #/
            (?x)
            (?:
                \.get\("n"\)\)&&\(b=|
                (?:
                    b=String\.fromCharCode\(110\)|
                    (?P<str_idx>[a-zA-Z0-9_$.]+)&&\(b="nn"\[\+(?P=str_idx)\]
                )
                (?:
                    ,[a-zA-Z0-9_$]+\(a\))?,c=a\.
                    (?:
                        get\(b\)|
                        [a-zA-Z0-9_$]+\[b\]\|\|null
                    )\)&&\(c=
            )(?P<nfunc>[a-zA-Z0-9_$]+)(?:\[(?P<idx>\d+)\])?\([a-zA-Z]\)
            /#
            
            if let match = try patternWithVar.firstMatch(in: js) {
                functionName = String(match.nfunc)
                index = match.idx.flatMap { Int($0) }
            } else if let match = try patternWithoutVar.firstMatch(in: js) {
                functionName = String(match.nfunc)
                index = match.idx.flatMap { Int($0) }
            } else {
                throw YouTubeKitError.regexMatchError
            }
            
            guard let index else {
                os_log("extracted throttle function name %{public}@ but no index", log: log, type: .error, functionName)
                throw YouTubeKitError.regexMatchError
            }
            
            let arrayPattern = NSRegularExpression(#"var "# + NSRegularExpression.escapedPattern(for:functionName) + #"\s*=\s*(\[.+?\])\s*[,;]"#)
            if let arrayMatch = arrayPattern.firstMatch(in: js, group: 1) {
                let array = arrayMatch.content.strip(from: "[]").split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                if array.indices.contains(index) {
                    return array[index]
                }
            }
            
        } else {
            
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
                let arrayPattern = NSRegularExpression(#"var "# + NSRegularExpression.escapedPattern(for: firstGroup.content) + #"\s*=\s*(\[.+?\])\s*[,;]"#)
                if let arrayMatch = arrayPattern.firstMatch(in: js, group: 1) {
                    let array = arrayMatch.content.strip(from: "[]").split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    if array.indices.contains(index) {
                        return array[index]
                    }
                }
            }
        }
        
        throw YouTubeKitError.regexMatchError
    }
    
    // MARK: - Global Var Extraction
    
    private struct PlayerGlobalVar {
        let name: String
        let globalList: [String]
        let code: String
    }
    
    private class func extractPlayerGlobalVar(js: String) throws -> (code: String, name: String, value: String)? {
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            
            let pattern = #/
            (?x)
            (?P<q1>["\'])use\s+strict(?P=q1);\s*
            (?P<code>
                var\s+(?P<name>[a-zA-Z0-9_$]+)\s*=\s*
                (?P<value>
                    (?P<q2>["\'])(?:(?!(?P=q2)).|\\.)+(?P=q2)
                    \.split\((?P<q3>["\'])(?:(?!(?P=q3)).)+(?P=q3)\)
                    |\[\s*(?:(?P<q4>["\'])(?:(?!(?P=q4)).|\\.)*(?P=q4)\s*,?\s*)+\]
                )
            )[;,]
            /#
            
            if let match = try pattern.firstMatch(in: js) {
                let code = String(match.code)
                let name = String(match.name)
                let value = String(match.value)
                
                return (code, name, value)
            }
            
            return nil
            
        } else {
            // TODO: currently not supported on older platforms
            return nil
        }
    }
    
    private class func interpretPlayerGlobalVar(js: String) throws -> PlayerGlobalVar? {
        
        guard let (code, name, value) = try extractPlayerGlobalVar(js: js) else {
            return nil
        }
        
#if canImport(JavaScriptCore)
        guard let context = JSContext() else {
            os_log("failed to create JSContext", log: log, type: .error)
            return nil
        }
        
        guard let expressionResult = context.evaluateScript(value), expressionResult.isArray else {
            os_log("failed to evaluate globalvar script", log: log, type: .error)
            return nil
        }
        let globalList = expressionResult.toArray() as? [String] ?? []
        
        return PlayerGlobalVar(name: name, globalList: globalList, code: code)
#else
        return nil
#endif
    }
    
    // MARK: -
    
    private class func extractFunctionCode(name: String, js: String) throws -> (variableName: String, code: String) {
        
        let args: String
        let codeStart: String.Index
        
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            let pattern = #"""
            (?xs)
            (?:
                function\s+{{name}}|
                [{;,]\s*{{name}}\s*=\s*function|
                (?:var|const|let)\s+{{name}}\s*=\s*function
            )\s*
            \((?P<args>[^)]*)\)\s*
            (?P<code>{.+})
            """#.replacingOccurrences(of: "{{name}}", with: name)
            if let match = try Regex(pattern).firstMatch(in: js) {
                args = String(match.output["args"]?.substring ?? "")
                codeStart = match.output["code"]?.range?.lowerBound ?? match.range.lowerBound
            } else {
                throw YouTubeKitError.regexMatchError
            }
            
        } else {
            let regex = NSRegularExpression(NSRegularExpression.escapedPattern(for: name) + #"=function\((\w)\)"#)
            guard let (match, groupMatches) = regex.firstMatch(in: js, includingGroups: [1]) else {
                throw YouTubeKitError.regexMatchError
            }
            
            guard let variableName = groupMatches[1]?.content else {
                throw YouTubeKitError.regexMatchError
            }
            
            args = variableName
            codeStart = match.end
        }
        
        let code = try Parser.findJavascriptFunctionFromStartpoint(html: js, startPoint: codeStart)
        return (args, code)
    }
    
    /// Extract the raw code for the throttling function.
    class func getThrottlingFunctionCode(js: String, functionName: String = "processNSignature") throws -> String {
        
        let globalVar = try interpretPlayerGlobalVar(js: js)
        
        let name = try getThrottlingFunctionName(js: js, globalVar: globalVar)
        
        var (variableName, code) = try extractFunctionCode(name: name, js: js)
        
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            if let globalVar {
                
                //code = globalVar.code + "; " + code (but removing opening and closing curly braces)
                code = globalVar.code + "; " + code[code.index(after: code.startIndex)..<code.index(before: code.endIndex)]
                code = "{" + code + "}"  // re-add curly braces
                
                let undefinedIndex = globalVar.globalList.firstIndex(where: { $0 == "undefined" })
                let undefinedIndexRegex = undefinedIndex.map { String($0) } ?? #"\d+"# // alternatively we match all integers
                
                let fixupPattern = #"""
                    (?x)
                    ;\s*if\s*\(\s*typeof\s+[a-zA-Z0-9_$]+\s*===?\s*(?:
                        (["\'])undefined\1|
                        {{varname}}\[{{undefined_idx}}\]
                    )\s*\)\s*return\s+{{argname}};
                    """#
                    .replacingOccurrences(of: "{{varname}}", with: globalVar.name)
                    .replacingOccurrences(of: "{{undefined_idx}}", with: undefinedIndexRegex)
                    .replacingOccurrences(of: "{{argname}}", with: variableName)
                
                let fixupRegex = try Regex(fixupPattern)
                code.replace(fixupRegex, with: ";")
            }
        }
        
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
