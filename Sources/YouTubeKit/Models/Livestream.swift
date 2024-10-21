//
//  Stream.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.08.23.
//

import Foundation

public struct Livestream: Sendable {
    
    public enum StreamType: Sendable {
        case hls
    }
    
    public let url: URL
    public let streamType: StreamType
    
}
