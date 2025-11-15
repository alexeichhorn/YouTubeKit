//
//  StreamQuery.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public extension Collection where Element == Stream {
    
    func sorted<T: Comparable>(by keyPath: KeyPath<Stream, T>, ascending: Bool = true) -> [Stream] {
        if ascending {
            return sorted { a, b in
                return a[keyPath: keyPath] < b[keyPath: keyPath]
            }
        } else {
            return sorted { a, b in
                return a[keyPath: keyPath] > b[keyPath: keyPath]
            }
        }
    }
    
    func stream(withITag itag: Int) -> Stream? {
        first(where: { $0.itag.itag == itag })
    }
    
    func streams(withExactResolution resolution: Int) -> [Stream] {
        filter { $0.itag.videoResolution == resolution }
    }
    
    func filter(byResolution resolution: (Int?) -> Bool) -> [Stream] {
        filter { resolution($0.itag.videoResolution) }
    }
    
    /// get stream with lowest video resolution
    func lowestResolutionStream() -> Stream? {
        min(byProperty: { $0.itag.videoResolution ?? .max })
    }
    
    /// get stream with highest video resolution
    func highestResolutionStream() -> Stream? {
        max(byProperty: { $0.itag.videoResolution ?? 0 })
    }
    
    /// get stream with lowest audio bitrate
    /// - note: potentially returns stream without audio if none exist
    func lowestAudioBitrateStream() -> Stream? {
        min(byProperty: { $0.itag.audioBitrate ?? .max })
    }
    
    /// get stream with highest audio bitrate
    /// - note: potentially returns stream without audio if none exist
    func highestAudioBitrateStream() -> Stream? {
        max(byProperty: { $0.itag.audioBitrate ?? 0 })
    }
    
    /// only returns streams which contain audio, but no video
    func filterAudioOnly() -> [Stream] {
        filter { $0.includesAudioTrack && !$0.includesVideoTrack }
    }
    
    /// only returns streams which contain video, but no audio
    func filterVideoOnly() -> [Stream] {
        filter { $0.includesVideoTrack && !$0.includesAudioTrack }
    }
    
    /// only returns streams which contain both audio and video
    func filterVideoAndAudio() -> [Stream] {
        filter { $0.includesVideoAndAudioTrack }
    }
    
}
