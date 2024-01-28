//
//  RemoteStream.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 29.08.23.
//

import Foundation

struct RemoteStream: Decodable {
    let url: URL
    let itag: Int
    let ext: String
    
    let videoCodec: String?
    let audioCodec: String?
    
    let averageBitrate: Int?
    let audioBitrate: Int?
    let videoBitrate: Int?
    let filesize: Int?
}
