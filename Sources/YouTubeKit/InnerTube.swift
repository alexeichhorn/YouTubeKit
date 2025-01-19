//
//  InnerTube.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 05.09.21.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
class InnerTube {
    
    private struct Client {
        let name: String
        let version: String
        let screen: String?
        let apiKey: String
        let internalID: Int
        let userAgent: String?
        var playerParams: String? = nil

        var androidSdkVersion: Int? = nil
        var deviceModel: String? = nil
        
        var context: Context {
            return Context(client: InnerTube.Context.ContextClient(clientName: name, clientVersion: version, clientScreen: screen, androidSdkVersion: androidSdkVersion, deviceModel: deviceModel))
        }
        
        var headers: [String: String] {
            [
                "User-Agent": userAgent ?? "",
                "X-Youtube-Client-Version": version,
                "X-Youtube-Client-Name": "\(internalID)",
            ].filter { !$0.value.isEmpty }
        }
    }
    
    private struct Context: Encodable {
        let client: ContextClient
        
        struct ContextClient: Encodable {
            let clientName: String
            let clientVersion: String
            let clientScreen: String?
            let androidSdkVersion: Int?
            let deviceModel: String?
        }
    }
    
    // overview of clients: https://github.com/zerodytrash/YouTube-Internal-Clients
    private let defaultClients = [
        ClientType.web: Client(name: "WEB", version: "2.20200720.00.02", screen: nil, apiKey: "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8", internalID: 1, userAgent: "Mozilla/5.0"),
        ClientType.webSafari: Client(name: "WEB", version: "2.20240726.00.00", screen: nil, apiKey: "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8", internalID: 1, userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15,gzip(gfe)"),
        ClientType.android: Client(name: "ANDROID", version: "19.09.37", screen: nil, apiKey: "AIzaSyA8eiZmM1FaDVjRy-df2KTyQ_vz_yYM39w", internalID: 3, userAgent: "com.google.android.youtube/19.09.37 (Linux; U; Android 11) gzip", playerParams: "CgIQBg==", androidSdkVersion: 30),
        ClientType.androidMusic: Client(name: "ANDROID_MUSIC", version: "5.16.51", screen: nil, apiKey: "AIzaSyAOghZGza2MQSZkY_zfZ370N-PUdXEo8AI", internalID: 21, userAgent: "com.google.android.apps.youtube.music/5.16.51 (Linux; U; Android 11) gzip", playerParams: "CgIQBg==", androidSdkVersion: 30),
        ClientType.androidVR: Client(name: "ANDROID_VR", version: "1.60.19", screen: nil, apiKey: "", internalID: 28, userAgent: "com.google.android.apps.youtube.vr.oculus/1.60.19 (Linux; U; Android 12L; eureka-user Build/SQ3A.220605.009.A1) gzip"),
        ClientType.webEmbed: Client(name: "WEB_EMBEDDED_PLAYER", version: "1.20220731.00.00", screen: "EMBED", apiKey: "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8", internalID: 56, userAgent: "Mozilla/5.0"),
        ClientType.webCreator: Client(name: "WEB_CREATOR", version: "1.20240723.03.00", screen: nil, apiKey: "", internalID: 62, userAgent: nil),
        ClientType.androidEmbed: Client(name: "ANDROID_EMBEDDED_PLAYER", version: "18.11.34", screen: "EMBED", apiKey: "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8", internalID: 3, userAgent: "com.google.android.youtube/18.11.34 (Linux; U; Android 11) gzip"),
        ClientType.tv: Client(name: "TVHTML5", version: "7.20241201.18.00", screen: nil, apiKey: "", internalID: 7, userAgent: nil),
        ClientType.tvEmbed: Client(name: "TVHTML5_SIMPLY_EMBEDDED_PLAYER", version: "2.0", screen: "EMBED", apiKey: "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8", internalID: 85, userAgent: "Mozilla/5.0"),
        ClientType.ios: Client(name: "IOS", version: "19.45.4", screen: nil, apiKey: "", internalID: 5, userAgent: "com.google.ios.youtube/19.45.4 (iPhone16,2; U; CPU iOS 18_1_0 like Mac OS X;)", deviceModel: "iPhone16,2"),
        ClientType.iosMusic: Client(name: "IOS_MUSIC", version: "5.21", screen: nil, apiKey: "AIzaSyBAETezhkwP0ZWA02RsqT1zu78Fpt0bC_s", internalID: 26, userAgent: "com.google.ios.youtubemusic/5.21 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)", deviceModel: "iPhone14,3"),
        ClientType.mediaConnectFrontend: Client(name: "MEDIA_CONNECT_FRONTEND", version: "0.1", screen: nil, apiKey: "", internalID: 0, userAgent: nil),
        ClientType.mWeb: Client(name: "MWEB", version: "2.20240726.01.00", screen: nil, apiKey: "", internalID: 2, userAgent: nil)
    ]
    
    enum ClientType: String {
        case web, webSafari, android, androidMusic, androidVR, webEmbed, webCreator, androidEmbed, tv, tvEmbed, ios, iosMusic, mediaConnectFrontend, mWeb
    }
    
    private var accessToken: String?
    private var refreshToken: String?
    
    private let useOAuth: Bool
    private let allowCache: Bool
    
    private let apiKey: String
    private let context: Context
    private let headers: [String: String]
    private let playerParams: String

    private let ytcfg: Extraction.YtCfg
    private let signatureTimestamp: Int?
    
    private let baseURL = "https://www.youtube.com/youtubei/v1"
    
    init(client: ClientType = .ios, signatureTimestamp: Int?, ytcfg: Extraction.YtCfg, useOAuth: Bool = false, allowCache: Bool = true) {
        self.context = defaultClients[client]!.context
        self.apiKey = defaultClients[client]!.apiKey
        self.headers = defaultClients[client]!.headers
        self.playerParams = defaultClients[client]!.playerParams ?? "8AEB"
        self.signatureTimestamp = signatureTimestamp
        self.ytcfg = ytcfg
        self.useOAuth = useOAuth
        self.allowCache = allowCache
        
        if useOAuth && allowCache {
            // TODO: load from cache file
        }
    }
    
    func cacheTokens() {
        guard allowCache else { return }
        // TODO: cache access and refresh tokens
    }
    
    func refreshBearerToken(force: Bool = false) {
        guard useOAuth else { return }
        // TODO: implement refresh of access token
    }
    
    func fetchBearerToken() {
        // TODO: fetch tokens
    }
    
    private struct BaseData: Encodable {
        let context: Context
    }
    
    private var baseData: BaseData {
        return BaseData(context: context)
    }
    
    private var baseParams: [URLQueryItem] {
        [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "contentCheckOk", value: "true"),
            URLQueryItem(name: "racyCheckOk", value: "true")
        ]
    }
    
    private func callAPI<D: Encodable, T: Decodable>(endpoint: String, query: [URLQueryItem], object: D) async throws -> T {
        let data = try JSONEncoder().encode(object)
        return try await callAPI(endpoint: endpoint, query: query, data: data)
    }
    
    private func callAPI<T: Decodable>(endpoint: String, query: [URLQueryItem], data: Data) async throws -> T {
        
        // TODO: handle oauth case
        
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = query
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "post"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ytcfg.userAgent ?? "Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.addValue("en-US,en", forHTTPHeaderField: "accept-language")
        
        request.addValue(ytcfg.visitorData ?? "", forHTTPHeaderField: "X-Goog-Visitor-Id")
        request.addValue("https://www.youtube.com", forHTTPHeaderField: "Origin")
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // TODO: handle oauth auth case again
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(T.self, from: responseData)
    }
    
    struct VideoInfo: Decodable {
        let playabilityStatus: PlayabilityStatus?
        let streamingData: StreamingData?
        let videoDetails: VideoDetails?

        struct PlayabilityStatus: Decodable {
            let status: String?
            let reason: String?
        }

        struct VideoDetails: Decodable {
            let videoId: String
            let title: String?
            let shortDescription: String?
            let thumbnail: Thumbnail

            struct Thumbnail: Decodable {
                let thumbnails: [ThumbnailMetadata]

                struct ThumbnailMetadata: Decodable {
                    let url: URL
                    let width: Int
                    let height: Int
                }
            }
        }
    }
    
    struct StreamingData: Decodable {
        let expiresInSeconds: String?
        let formats: [Format]?
        let adaptiveFormats: [Format]? // actually slightly different Format object (TODO)
        let onesieStreamingUrl: String?
        let hlsManifestUrl: String?
        
        struct Format: Decodable {
            let itag: Int
            var url: String?
            let mimeType: String
            let bitrate: Int?
            let width: Int?
            let height: Int?
            let lastModified: String?
            let contentLength: String?
            let quality: String
            let fps: Int?
            let qualityLabel: String?
            let averageBitrate: Int?
            let audioQuality: String?
            let approxDurationMs: String?
            let audioSampleRate: String?
            let audioChannels: Int?
            let signatureCipher: String? // not tested yet
            var s: String? // assigned from Extraction.applyDescrambler
        }
    }
    
    private struct PlaybackContext: Encodable {
        let contentPlaybackContext: Context
        
        struct Context: Encodable {
            let html5Preference = "HTML5_PREF_WANTS"
            let signatureTimestamp: Int?
        }
    }
    
    private struct PlayerRequest: Encodable {
        let context: Context
        let videoId: String
        let params: String
        let playbackContext: PlaybackContext
        let contentCheckOk: Bool = true
        let racyCheckOk: Bool = true
    }
    
    private func playerRequest(forVideoID videoID: String) -> PlayerRequest {
        let playbackContext = PlaybackContext(contentPlaybackContext: PlaybackContext.Context(signatureTimestamp: signatureTimestamp))
        return PlayerRequest(context: context, videoId: videoID, params: playerParams, playbackContext: playbackContext)
    }
    
    func player(videoID: String) async throws -> VideoInfo {
        let endpoint = baseURL + "/player"
        let query = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "prettyPrint", value: "false")
        ].filter { !($0.value?.isEmpty ?? true) }
        let request = playerRequest(forVideoID: videoID)
        return try await callAPI(endpoint: endpoint, query: query, object: request)
    }
    
    // TODO: change result type
    func search(query: String, continuation: String? = nil) async throws -> [String: String] {
        
        struct SearchObject: Encodable {
            let context: Context
            let continuation: String?
        }
        
        let query = baseParams + [
            URLQueryItem(name: "query", value: query)
        ]
        let object = SearchObject(context: context, continuation: continuation)
        return try await callAPI(endpoint: baseURL + "/search", query: query, object: object)
    }
    
    // TODO: change result type
    func verifyAge(videoID: String) async throws -> [String: String] {
        
        struct RequestObject: Encodable {
            let nextEndpoint: NextEndpoint
            let setControvercy: Bool
            let context: Context
            
            struct NextEndpoint: Encodable {
                let urlEndpoint: URLEndpoint
            }
            
            struct URLEndpoint: Encodable {
                let url: String
            }
        }
        
        let object = RequestObject(nextEndpoint: RequestObject.NextEndpoint(urlEndpoint: RequestObject.URLEndpoint(url: "/watch?v=\(videoID)")), setControvercy: true, context: context)
        return try await callAPI(endpoint: baseURL + "/verify_age", query: baseParams, object: object)
    }
    
    // TODO: change result type
    func getTranscript(videoID: String) async throws -> [String: String] {
        let query = baseParams + [
            URLQueryItem(name: "videoID", value: videoID)
        ]
        return try await callAPI(endpoint: baseURL + "/get_transcript", query: query, object: baseData)
    }
    
}
