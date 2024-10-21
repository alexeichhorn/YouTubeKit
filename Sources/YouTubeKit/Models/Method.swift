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
        case local
        case remote(serverURL: URL)
        
        public static var remote: ExtractionMethod {
            return .remote(serverURL: URL(string: "https://youtubekit-remote.losjet.com")!)
        }
    }
    
}
