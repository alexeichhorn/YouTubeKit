//
//  Stream.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.08.23.
//

import Foundation

public struct Livestream {
    
    public enum StreamType {
        case hls
    }
    
    public let url: URL
    public let streamType: StreamType
    
}
