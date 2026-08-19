//
//  HLSURLAsset.swift
//  YouTubeKit
//

import AVFoundation
import Foundation

final class HLSURLAsset: AVURLAsset, @unchecked Sendable {
    private let playlistLoader: HLSPlaylistResourceLoader

    init(url: URL, playlists: [String: String]) {
        let playlistLoader = HLSPlaylistResourceLoader(playlists: playlists)
        self.playlistLoader = playlistLoader
        super.init(url: url, options: nil)
        resourceLoader.setDelegate(
            playlistLoader,
            queue: DispatchQueue(label: "YouTubeKit.HLSPlaylistResourceLoader")
        )
    }
}

private final class HLSPlaylistResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    private let playlists: [String: Data]

    init(playlists: [String: String]) {
        self.playlists = playlists.mapValues { Data($0.utf8) }
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard let url = loadingRequest.request.url,
              let data = playlists[url.path] else {
            return false
        }

        loadingRequest.contentInformationRequest?.contentType = "public.m3u-playlist"
        loadingRequest.contentInformationRequest?.contentLength = Int64(data.count)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true

        if let dataRequest = loadingRequest.dataRequest {
            guard dataRequest.currentOffset >= 0,
                  dataRequest.currentOffset <= Int64(data.count) else {
                loadingRequest.finishLoading(with: HLSPlayerItemError.invalidResponse)
                return true
            }
            let start = Int(dataRequest.currentOffset)
            let end = start + min(dataRequest.requestedLength, data.count - start)
            if start < end {
                dataRequest.respond(with: data[start..<end])
            }
        }

        loadingRequest.finishLoading()
        return true
    }
}
