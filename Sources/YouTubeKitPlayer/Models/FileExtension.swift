//
//  FileExtension.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 29.08.23.
//

import Foundation

public enum FileExtension: String, Sendable {
    // video
    case threegp = "3gp"
    case ts
    case mp4
    case mpeg
    case m3u8
    case mov
    case vp9
    case flv
    case m4v
    case mkv
    case mng
    case asf
    case wmv
    case avi
    
    // audio
    case m4a
    case mp3
    case mka
    case m3u
    case mid
    case ogg
    case wav
    case aac
    case flac
    case ra
    
    // audio or video
    case webm
    
    // extra
    case unknown
    
    
    init(mimeType: String) {
        // similar map to the one in `youtube-dl`
        let map: [String: FileExtension] = [
            // video
            "3gpp": .threegp,
            "mp2t": .ts,
            "mp4": .mp4,
            "mpeg": .mpeg,
            "mpegurl": .m3u8,
            "quicktime": .mov,
            "webm": .webm,
            "vp9": .vp9,
            "x-flv": .flv,
            "x-m4v": .m4v,
            "x-matroska": .mkv,
            "x-mng": .mng,
            "x-mp4-fragmented": .mp4,
            "x-ms-asf": .asf,
            "x-ms-wmv": .wmv,
            "x-msvideo": .avi,
            
            // audio
            "audio/mp4": .m4a,
            "audio/mpeg": .mp3,
            "audio/webm": .webm,
            "audio/x-matroska": .mka,
            "audio/x-mpegurl": .m3u,
            "midi": .mid,
            "ogg": .ogg,
            "wav": .wav,
            "wave": .wav,
            "x-aac": .aac,
            "x-flac": .flac,
            "x-m4a": .m4a,
            "x-realaudio": .ra,
            "x-wav": .wav,
        ]
        
        if let fileExtension = map[mimeType] {
            self = fileExtension
        } else if let subtype = mimeType.split(separator: "/").last,
                  let fileExtension = map[String(subtype)] {
            self = fileExtension
        } else {
            self = .unknown
        }
    }
}
