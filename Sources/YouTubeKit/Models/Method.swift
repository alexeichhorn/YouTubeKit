//
//  Method.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 31.08.23.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension YouTube {
    
    public enum ExtractionMethod: Hashable, Sendable {
#if canImport(JavaScriptCore)
        case local
#endif
        case remote(serverURL: URL)
        
        public static var remote: ExtractionMethod {
            return .remote(serverURL: URL(string: "https://remote-production.youtubekit.dev")!)
        }
    }
    
}

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension [YouTube.ExtractionMethod] {

    /// Some platforms (i.e. watchOS) don't support javascript execution, which makes local evaluation impossible
    public static var `default`: Self {
#if canImport(JavaScriptCore)
        [.local]
#else
        [.remote]
#endif
    }

}
