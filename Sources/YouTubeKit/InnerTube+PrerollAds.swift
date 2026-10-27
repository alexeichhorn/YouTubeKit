//
//  InnerTube+PrerollAds.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 27.10.26.
//

import Foundation

/// Stream URLs of a player response with preroll ads return 403 until those ads could have been watched or skipped.
/// Requesting them earlier can make them fail permanently (see https://github.com/alexeichhorn/YouTubeKit/issues/94).
@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension InnerTube.VideoInfo {

    var streamsAvailableAt: Date {
        receivedAt.addingTimeInterval(prerollWaitDuration)
    }

    var prerollWaitDuration: TimeInterval {
        let slotAds = (adSlots ?? [])
            .filter { $0.adSlotRenderer.adSlotMetadata?.triggerEvent == "SLOT_TRIGGER_EVENT_BEFORE_CONTENT" }
            .flatMap { $0.adSlotRenderer.fulfillmentContent?.fulfilledLayout?.playerBytesAdLayoutRenderer?.renderingContent?.videoAds ?? [] }
        let placementAds = (adPlacements ?? [])
            .filter { $0.adPlacementRenderer.config?.adPlacementConfig?.kind == "AD_PLACEMENT_KIND_START" }
            .compactMap { $0.adPlacementRenderer.renderer?.instreamVideoAdRenderer }
        return (slotAds + placementAds).map(\.waitDuration).reduce(0, +)
    }

    /// Ad format of web clients.
    struct AdSlot: Decodable {
        let adSlotRenderer: Renderer

        struct Renderer: Decodable {
            let adSlotMetadata: Metadata?
            let fulfillmentContent: FulfillmentContent?
        }

        struct Metadata: Decodable {
            let triggerEvent: String?
        }

        struct FulfillmentContent: Decodable {
            let fulfilledLayout: Layout?
        }

        struct Layout: Decodable {
            let playerBytesAdLayoutRenderer: LayoutRenderer?
        }

        struct LayoutRenderer: Decodable {
            let renderingContent: RenderingContent?
        }

        struct RenderingContent: Decodable {
            let instreamVideoAdRenderer: VideoAd?
            let playerBytesSequentialLayoutRenderer: SequentialLayoutRenderer?

            var videoAds: [VideoAd] {
                let sequentialAds = playerBytesSequentialLayoutRenderer?.sequentialLayouts?
                    .flatMap { $0.playerBytesAdLayoutRenderer?.renderingContent?.videoAds ?? [] } ?? []
                return (instreamVideoAdRenderer.map { [$0] } ?? []) + sequentialAds
            }
        }

        struct SequentialLayoutRenderer: Decodable {
            let sequentialLayouts: [Layout]?
        }
    }

    /// Ad format of TV clients.
    struct AdPlacement: Decodable {
        let adPlacementRenderer: Renderer

        struct Renderer: Decodable {
            let config: Config?
            let renderer: Content?
        }

        struct Config: Decodable {
            let adPlacementConfig: PlacementConfig?
        }

        struct PlacementConfig: Decodable {
            let kind: String?
        }

        struct Content: Decodable {
            let instreamVideoAdRenderer: VideoAd?
        }
    }

    struct VideoAd: Decodable {
        let skipOffsetMilliseconds: Int?
        /// URL query string that includes `length_seconds`
        let playerVars: String?

        /// Skippable ads only need to be waited for until they can be skipped.
        var waitDuration: TimeInterval {
            if let skipOffsetMilliseconds {
                return TimeInterval(skipOffsetMilliseconds) / 1000
            }
            let lengthSeconds = playerVars
                .flatMap { URLComponents(string: "?\($0)")?.queryItems }?
                .first { $0.name == "length_seconds" }?
                .value
            return lengthSeconds.flatMap(TimeInterval.init) ?? 0
        }
    }
}
