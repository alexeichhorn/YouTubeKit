//
//  YouTube.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public class YouTube {
    
    private var _js: String?
    private var _jsURL: URL?
    
    private static var __js: String? // caches js between calls
    private static var __jsURL: URL?
    
    private var _videoInfo: InnerTube.VideoInfo?
    
    private var _watchHTML: String?
    private var _embedHTML: String?
    private var playerConfigArgs: [String: Any]?
    private var _ageRestricted: Bool?
    
    private var _fmtStreams: [Stream]?
    
    private var initialData: Data?
    private var metadata: YouTubeMetadata?
    
    public let videoID: String
    
    var watchURL: URL {
        URL(string: "https://youtube.com/watch?v=\(videoID)")!
    }
    
    var embedURL: URL {
        URL(string: "https://www.youtube.com/embed/\(videoID)")!
    }
    
    // stream monostate TODO
    
    private var author: String?
    private var title: String?
    private var publishDate: String?
    
    let useOAuth: Bool
    let allowOAuthCache: Bool
    
    public init(videoID: String, proxies: [String: URL] = [:], useOAuth: Bool = false, allowOAuthCache: Bool = false) {
        self.videoID = videoID
        self.useOAuth = useOAuth
        self.allowOAuthCache = allowOAuthCache
        // TODO: install proxies if needed
    }
    
    public convenience init(url: URL, proxies: [String: URL] = [:], useOAuth: Bool = false, allowOAuthCache: Bool = false) {
        let videoID = Extraction.extractVideoID(from: url.absoluteString) ?? ""
        self.init(videoID: videoID, proxies: proxies, useOAuth: useOAuth, allowOAuthCache: allowOAuthCache)
    }
    
    
    private var watchHTML: String {
        get async throws {
            if let cached = _watchHTML {
                return cached
            }
            var request = URLRequest(url: watchURL)
            request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
            request.setValue("en-US,en", forHTTPHeaderField: "accept-language")
            let (data, _) = try await URLSession.shared.data(for: request)
            _watchHTML = String(data: data, encoding: .utf8) ?? ""
            return _watchHTML!
        }
    }
    
    private var embedHTML: String {
        get async throws {
            if let cached = _embedHTML {
                return cached
            }
            var request = URLRequest(url: embedURL)
            request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
            request.setValue("en-US,en", forHTTPHeaderField: "accept-language")
            let (data, _) = try await URLSession.shared.data(for: request)
            _embedHTML = String(data: data, encoding: .utf8) ?? ""
            return _embedHTML!
        }
    }
    
    
    /// check whether the video is available
    public func checkAvailability() async throws {
        let (status, messages) = try Extraction.playabilityStatus(watchHTML: await watchHTML)
        let streamingData = try await videoInfo.streamingData

        for reason in messages {
            switch status {
            case .unplayable:
                if reason?.starts(with: "Join this channel to get access to members-only content") ?? false { // TODO: original compared to tuple
                    throw YouTubeKitError.membersOnly
                }
            case .loginRequired:
                if reason.map({ $0.starts(with: "This is a private video") || $0.starts(with: "This video is private") }) ?? false { // TODO: original: reason == ["This is a private video. ", "Please sign in to verify that you may see it."] {
                    throw YouTubeKitError.videoPrivate
                }
            case .error:
                throw YouTubeKitError.videoUnavailable
            case .liveStream where streamingData?.hlsManifestUrl == nil :
                throw YouTubeKitError.liveStreamError
            case .ok, .none, .liveStream:
                continue
            }
        }
    }
    
    public var ageRestricted: Bool {
        get async throws {
            if let cached = _ageRestricted {
                return cached
            }
            
            _ageRestricted = try await Extraction.isAgeRestricted(watchHTML: watchHTML)
            return _ageRestricted!
        }
    }
    
    var jsURL: URL {
        get async throws {
            if let cached = _jsURL {
                return cached
            }
            
            if try await ageRestricted {
                _jsURL = try await URL(string: Extraction.jsURL(html: embedHTML))!
            } else {
                _jsURL = try await URL(string: Extraction.jsURL(html: watchHTML))!
            }
            return _jsURL!
        }
    }
    
    var js: String {
        get async throws {
            if let cached = _js {
                return cached
            }
            
            let jsURL = try await jsURL
            
            if YouTube.__jsURL != jsURL {
                let (data, _) = try await URLSession.shared.data(from: jsURL)
                _js = String(data: data, encoding: .utf8) ?? ""
                YouTube.__js = _js
                YouTube.__jsURL = jsURL
            } else {
                _js = YouTube.__js
            }
            return _js!
        }
    }
    
    /// Interface to query both adaptive (DASH) and progressive streams.
    /// Returns a list of streams if they have been initialized.
    /// If the streams have not been initialized, finds all relevant streams and initializes them.
    public var streams: [Stream] {
        get async throws {
            try await checkAvailability()
            if let cached = _fmtStreams {
                return cached
            }
            
            var streamManifest = Extraction.applyDescrambler(streamData: try await streamingData)
            
            do {
                try await Extraction.applySignature(streamManifest: &streamManifest, videoInfo: videoInfo, js: js)
            } catch {
                // to force an update to the js file, we clear the cache and retry
                _js = nil
                _jsURL = nil
                YouTube.__js = nil
                YouTube.__jsURL = nil
                try await Extraction.applySignature(streamManifest: &streamManifest, videoInfo: videoInfo, js: js)
            }
            
            let result = streamManifest.compactMap { try? Stream(format: $0) }
            
            _fmtStreams = result
            return result
        }
    }
    
    /// Returns a list of live streams - currently only HLS supported
    public var livestreams: [Livestream] {
        get async throws {
            var livestreams = [Livestream]()
            if let hlsManifestUrl = try await streamingData.hlsManifestUrl.flatMap({ URL(string: $0) }) {
                livestreams.append(Livestream(url: hlsManifestUrl, streamType: .hls))
            }
            return livestreams
        }
    }

    /// streaming data from video info
    var streamingData: InnerTube.StreamingData {
        get async throws {
            if let streamingData = try await videoInfo.streamingData {
                return streamingData
            } else {
                try await bypassAgeGate()
                if let streamingData = try await videoInfo.streamingData {
                    return streamingData
                } else {
                    throw YouTubeKitError.extractError
                }
            }
        }
    }
    
    var videoInfo: InnerTube.VideoInfo {
        get async throws {
            if let cached = _videoInfo {
                return cached
            }
            
            let innertube = InnerTube(useOAuth: useOAuth, allowCache: allowOAuthCache)
            
            let innertubeResponse = try await innertube.player(videoID: videoID)
            _videoInfo = innertubeResponse
            return innertubeResponse
        }
    }
    
    private func bypassAgeGate() async throws {
        let innertube = InnerTube(client: .tvEmbed, useOAuth: useOAuth, allowCache: allowOAuthCache)
        let innertubeResponse = try await innertube.player(videoID: videoID)
        
        if innertubeResponse.playabilityStatus?.status == "UNPLAYABLE" || innertubeResponse.playabilityStatus?.status == "LOGIN_REQUIRED" {
            throw YouTubeKitError.videoAgeRestricted
        }
        
        _videoInfo = innertubeResponse
    }
    
    /// Interface to query both adaptive (DASH) and progressive streams.
    /*public var streams: StreamQuery {
        get async throws {
            //try await checkAvailability()
            return StreamQuery(fmtStreams: try await fmtStreams)
        }
    }*/
    
}
