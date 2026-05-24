//
//  SignatureTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 12.06.2025.
//

#if canImport(JavaScriptCore)
import Testing
import Foundation
@testable import YouTubeKit

struct SignatureTests {
    private static func utf8String(_ bytes: [UInt8]) -> String {
        String(decoding: bytes, as: UTF8.self)
    }

    private static func utf8RangeString(_ range: ClosedRange<Int>) -> String {
        utf8String(range.map(UInt8.init))
    }

    struct SignaturePlayerRequest: CustomTestStringConvertible {
        let playerURL: URL
        let pairs: [Pair]

        struct Pair {
            let input: String
            let output: String
        }

        init(playerURL: URL, input: String, output: String) {
            self.playerURL = playerURL
            self.pairs = [Pair(input: input, output: output)]
        }

        init(playerURL: URL, pairs: [Pair]) {
            self.playerURL = playerURL
            self.pairs = pairs
        }

        var testDescription: String {
            if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
                let regex = #/.+\/player\/(?<id>[a-zA-Z0-9_\/.-]+)\.js$/#
                if let match = playerURL.absoluteString.firstMatch(of: regex) {
                    return String(match.id)
                }
            }
            return playerURL.absoluteString
        }
    }

    private func downloadJavascript(fromURL url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        let js = String(data: data, encoding: .utf8)
        return try #require(js, "Failed to download JavaScript from \(url)")
    }

    @Test("Signature (legacy) over all players", arguments: [
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/6ed0d907/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "AOq0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xx8j7v1pDL2QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3bb1f723/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "MyOSJXtKI3m-uME_jv7-pT12gOFC02RFkGoqWpzE0Cs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/2f1832d2/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xxAj7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJ2OySqa0q"),
        //SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/643afba4/tv-player-ias.vflset/tv-player-ias.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "AAOAOq0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xx8j7vgpDL0QwbdV06sCIEzpWqMGkFR20CFOS21Tp-7vj_EMu-m37KtXJoOy1"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/363db69b/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpz2ICs6EVdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/363db69b/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpz2ICs6EVdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "wAOAOq0QJ8ARAIgXmPlOPSBkkUs1bYFYlJCfe29xx8q7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "wAOAOq0QJ8ARAIgXmPlOPSBkkUs1bYFYlJCfe29xx8q7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-phone-en_US.vflset/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
        //SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-tablet-en_US.vflset/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "IAOAOq0QJ8wRAAgXmPlOPSBkkUs1bYFYlJCfe29xx8j7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_E2u-m37KtXJoOySqa0"),
        //SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/tv-player-es6.vflset/tv-player-es6.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "IAOAOq0QJ8wRAAgXmPlOPSBkkUs1bYFYlJCfe29xx8j7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_E2u-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e12fbea4/player_ias.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "JC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEvaepit0zJAtIEsgOV2SXZjhSHMNy0NXNG_1kOyBf6HPuAuCduh-a"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/010fbc8d/player_es5.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "ttJC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEvaepit2zJAsIEggOVaSXZjhSHMNy0NXNG_1kOyBf6HPuAuCduh-"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/010fbc8d/player_es6.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "ttJC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEvaepit2zJAsIEggOVaSXZjhSHMNy0NXNG_1kOyBf6HPuAuCduh-"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5ec65609/player_ias_tcc.vflset/en_US/base.js")!, input: "AAJAJfQdSswRAIgNSN0GDUcHnCIXkKcF61yLBgDHiX1sUhOJdY4_GxunRYCIDeYNYP_16mQTPm5f1OVq3oV1ijUNYPjP4iUSMAjO9bZ", output: "AJfQdSswRAIgNSN0GDUcHnCIXkKcF61ZLBgDHiX1sUhOJdY4_GxunRYCIDyYNYP_16mQTPm5f1OVq3oV1ijUNYPjP4iUSMAjO9be"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0004de42/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv2-pT15gOFC02R7kGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qO"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0004de42/player_ias.vflset/en_US/base.js")!, input: "kJfAJfQdSswRgIhAIAVJyVrl-q9IeaMXTX9wuANotEnc3R9lQfdVaMFLa01AiEApmr1KuBrdE__Tc_p6_7QFuQI-arti18Yg1-Ac7xfjkg=kg==", output: "AJfQdSswRgIhAIAVJyVrlkq9IeaMXTX9wu-NotEnc3R9lQfdVaMFLa01AiEApmr1KuBrdE__Tc_p6_7QFuQI-arti18Yg1-Ac7xfjkg="),
    ])
    func signatureLegacyForPlayerURL(_ request: SignaturePlayerRequest) async throws {
        let js = try await downloadJavascript(fromURL: request.playerURL)
        let cipher = try Cipher(js: js)
        for pair in request.pairs {
            let calculatedSignature = cipher.getSignature(cipheredSignature: pair.input)
            #expect(calculatedSignature == pair.output)
        }
    }
    
    
    @Test("Signature over all players", arguments: [
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/6ed0d907/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "AOq0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xx8j7v1pDL2QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3bb1f723/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "MyOSJXtKI3m-uME_jv7-pT12gOFC02RFkGoqWpzE0Cs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/2f1832d2/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xxAj7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJ2OySqa0q"),
        //SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/643afba4/tv-player-ias.vflset/tv-player-ias.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "AAOAOq0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xx8j7vgpDL0QwbdV06sCIEzpWqMGkFR20CFOS21Tp-7vj_EMu-m37KtXJoOy1"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/363db69b/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpz2ICs6EVdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/363db69b/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpz2ICs6EVdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "wAOAOq0QJ8ARAIgXmPlOPSBkkUs1bYFYlJCfe29xx8q7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "wAOAOq0QJ8ARAIgXmPlOPSBkkUs1bYFYlJCfe29xx8q7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-phone-en_US.vflset/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-tablet-en_US.vflset/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "IAOAOq0QJ8wRAAgXmPlOPSBkkUs1bYFYlJCfe29xx8j7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_E2u-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/tv-player-es6.vflset/tv-player-es6.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "IAOAOq0QJ8wRAAgXmPlOPSBkkUs1bYFYlJCfe29xx8j7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_E2u-m37KtXJoOySqa0"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e12fbea4/player_ias.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "JC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEvaepit0zJAtIEsgOV2SXZjhSHMNy0NXNG_1kOyBf6HPuAuCduh-a"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/010fbc8d/player_es5.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "ttJC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEvaepit2zJAsIEggOVaSXZjhSHMNy0NXNG_1kOyBf6HPuAuCduh-"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/010fbc8d/player_es6.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "ttJC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEvaepit2zJAsIEggOVaSXZjhSHMNy0NXNG_1kOyBf6HPuAuCduh-"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5ec65609/player_ias_tcc.vflset/en_US/base.js")!, input: "AAJAJfQdSswRAIgNSN0GDUcHnCIXkKcF61yLBgDHiX1sUhOJdY4_GxunRYCIDeYNYP_16mQTPm5f1OVq3oV1ijUNYPjP4iUSMAjO9bZ", output: "AJfQdSswRAIgNSN0GDUcHnCIXkKcF61ZLBgDHiX1sUhOJdY4_GxunRYCIDyYNYP_16mQTPm5f1OVq3oV1ijUNYPjP4iUSMAjO9be"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0004de42/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv2-pT15gOFC02R7kGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qO"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0004de42/player_ias.vflset/en_US/base.js")!, input: "kJfAJfQdSswRgIhAIAVJyVrl-q9IeaMXTX9wuANotEnc3R9lQfdVaMFLa01AiEApmr1KuBrdE__Tc_p6_7QFuQI-arti18Yg1-Ac7xfjkg=kg==", output: "AJfQdSswRgIhAIAVJyVrlkq9IeaMXTX9wu-NotEnc3R9lQfdVaMFLa01AiEApmr1KuBrdE__Tc_p6_7QFuQI-arti18Yg1-Ac7xfjkg="),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3d3ba064/player_ias_tce.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "ttJC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3gqEctUw-NYdNmOEvaepit0zJAtIEsgOV2SXZjhSHMNy0NXNG_1kNyBf6HPuAuCduh-a7O"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5ec65609/player_ias_tce.vflset/en_US/base.js")!, input: "AAJAJfQdSswRQIhAMG5SN7-cAFChdrE7tLA6grH0rTMICA1mmDc0HoXgW3CAiAQQ4=CspfaF_vt82XH5yewvqcuEkvzeTsbRuHssRMyJQ=I", output: "AJfQdSswRQIhAMG5SN7-cAFChdrE7tLA6grI0rTMICA1mmDc0HoXgW3CAiAQQ4HCspfaF_vt82XH5yewvqcuEkvzeTsbRuHssRMyJQ=="),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/6742b2b9/player_ias_tce.vflset/en_US/base.js")!, input: "MMGZJMUucirzS_SnrSPYsc85CJNnTUi6GgR5NKn-znQEICACojE8MHS6S7uYq4TGjQX_D4aPk99hNU6wbTvorvVVMgIARwsSdQfJAA", output: "AJfQdSswRAIgMVVvrovTbw6UNh99kPa4D_XQjGT4qYu7S6SHM8EjoCACIEQnz-nKN5RgG6iUTnNJC58csYPSrnS_SzricuUMJZGM"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4e51e895/player_ias.vflset/en_US/base.js")!, input: "AL6p_8AwdY9yAhRzK8rYA_9n97Kizf7_9n97Kizf7_9n97Kizf7_9n97Kizf7_9n97Kizf7_9n97Kizf7", output: "AwdY9yAhRzK8rYA_9n97Kizf7_9n97Kizf7_9n9pKizf7_9n97Kizf7_9n97Kizf7_9n97Kizf7"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/54bd1de4/player_ias_tce.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0titeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtp"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/f104ea90/player_ias_tce.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "fJC2JtQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEZaepit0z7AtIEsgOV2SX-jhSHMNy0NXNG_1kOyBf6HPuAuCduhv"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3510b6ff/player_ias_tce.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "fJC2JtQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEZaepit0z7AtIEsgOV2SX-jhSHMNy0NXNG_1kOyBf6HPuAuCduhv"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0675bd00/player_ias_tce.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "fJC2JtQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEZaepit0z7AtIEsgOV2SX-jhSHMNy0NXNG_1kOyBf6HPuAuCduhv"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e0528946/player_ias_tce.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "7a-hudCuAuPH6fByOk1_GNXN0yNMgShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2C"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/94667337/player_es6.vflset/en_US/base.js")!, input: "NJAJEij0EwRgIhAI0KExTgjfPk-MPM9MAdzyyPRt=BM8-XO5tm5hlMCSVpAiEAv7eP3CURqZNSPow8BXXAoazVoXgeMP7gH9BdylHCwgw=gwzz", output: "AJEij0EwRgIhAI0KExTgjfPk-MPM9MNdzyyPRtzBM8-XO5tm5hlMCSVpAiEAv7eP3CURqZNSPow8BXXAoazVoXgeMP7gH9BdylHCwgw="),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/74edf1a3/tv-player-ias.vflset/tv-player-ias.js")!, pairs: [
            SignaturePlayerRequest.Pair(input: "NJAJEij0EwRgIhAI0KExTgjfPk-MPM9MAdzyyPRt=BM8-XO5tm5hlMCSVpAiEAv7eP3CURqZNSPow8BXXAoazVoXgeMP7gH9BdylHCwgw=gwzz", output: "NJAJEij0EwRgIhAI0KExTgjfPk-MPM9MAdzyyPRt=BM8-XO5tm5hzMCSVpAiEAv7eP3CURqZNSPow8BXXAoazVoXgeMP7gH9BdylHCwgw=gwzl"),
            SignaturePlayerRequest.Pair(
                input: Self.utf8String([0, 1, 2, 37, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49]),
                output: Self.utf8String([0, 1, 2, 37, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 49, 44, 45, 46, 47, 48, 43])
            )
        ]),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/901741ab/tv-player-ias.vflset/tv-player-ias.js")!, input: "NJAJEij0EwRgIhAI0KExTgjfPk-MPM9MAdzyyPRt=BM8-XO5tm5hlMCSVpAiEAv7eP3CURqZNSPow8BXXAoazVoXgeMP7gH9BdylHCwgw=gwzz", output: "wgwCHlydB9Hg7PMegXoVzaoAXXB8woPSNZqRUC3Pe7vAEiApVSCMlhwmt5ON-8MB=5RPyyzdAM9MPM-kPfjgTxEK0IAhIgRwE0jiEJA"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e7573094/tv-player-ias.vflset/tv-player-ias.js")!, input: "NJAJEij0EwRgIhAI0KExTgjfPk-MPM9MAdzyyPRt=BM8-XO5tm5hlMCSVpAiEAv7eP3CURqZNSPow8BXXAoazVoXgeMP7gH9BdylHCwgw=gwzz", output: "yEij0EwRgIhAI0KExTgjfPk-MPM9MAdzyNPRt=BM8-XO5tm5hlMCSVNAiEAvpeP3CURqZJSPow8BXXAoazVoXgeMP7gH9BdylHCwgw=g"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/9fcf08e8/player_ias.vflset/en_US/base.js")!, input: Self.utf8RangeString(0x00...0x6a), output: Self.utf8String([0x6a, 0x69, 0x68, 0x67, 0x66, 0x65, 0x64, 0x63, 0x62, 0x61, 0x60, 0x5f, 0x5e, 0x5d, 0x5c, 0x5b, 0x5a, 0x59, 0x58, 0x57, 0x56, 0x55, 0x54, 0x53, 0x52, 0x51, 0x50, 0x4f, 0x4e, 0x4d, 0x4c, 0x4b, 0x4a, 0x49, 0x48, 0x47, 0x46, 0x45, 0x44, 0x43, 0x42, 0x41, 0x40, 0x3f, 0x3e, 0x3d, 0x3c, 0x3b, 0x3a, 0x39, 0x38, 0x37, 0x36, 0x35, 0x34, 0x33, 0x32, 0x31, 0x30, 0x2f, 0x2e, 0x2d, 0x2c, 0x2b, 0x2a, 0x29, 0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21, 0x20, 0x1f, 0x1e, 0x1d, 0x1c, 0x1b, 0x1a, 0x19, 0x18, 0x17, 0x16, 0x15, 0x14, 0x13, 0x12, 0x11, 0x10, 0x0f, 0x0e, 0x0d, 0x0c, 0x0b, 0x03, 0x09, 0x08, 0x07, 0x06, 0x05, 0x04, 0x0a])),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/21cd2156/player_ias.vflset/en_US/base.js")!, input: Self.utf8RangeString(0x00...0x6a), output: Self.utf8String([0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43, 0x44, 0x00, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x6a, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x4c])),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/76ad2fe8/tv-player-ias.vflset/tv-player-ias.js")!, input: Self.utf8RangeString(0x00...0x6a), output: Self.utf8String([0x46, 0x66, 0x65, 0x64, 0x63, 0x62, 0x61, 0x60, 0x5f, 0x5e, 0x67, 0x6a, 0x5b, 0x5a, 0x59, 0x58, 0x57, 0x56, 0x55, 0x54, 0x53, 0x52, 0x51, 0x50, 0x4f, 0x4e, 0x4d, 0x4c, 0x4b, 0x4a, 0x49, 0x48, 0x47, 0x2c, 0x45, 0x44, 0x43, 0x42, 0x41, 0x40, 0x3f, 0x3e, 0x3d, 0x3c, 0x3b, 0x3a, 0x39, 0x38, 0x13, 0x36, 0x35, 0x34, 0x33, 0x32, 0x31, 0x30, 0x2f, 0x2e, 0x2d, 0x5d, 0x2b, 0x2a, 0x29, 0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21, 0x20, 0x1f, 0x1e, 0x1d, 0x1c, 0x1b, 0x1a, 0x19, 0x18, 0x17, 0x16, 0x15, 0x14, 0x0c, 0x12, 0x11, 0x10, 0x0f, 0x0e, 0x0d, 0x00, 0x0b, 0x0a, 0x09, 0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0x37])),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/76ad2fe8/tv-player-es6.vflset/tv-player-es6.js")!, input: Self.utf8RangeString(0x00...0x6a), output: Self.utf8String([0x46, 0x66, 0x65, 0x64, 0x63, 0x62, 0x61, 0x60, 0x5f, 0x5e, 0x67, 0x6a, 0x5b, 0x5a, 0x59, 0x58, 0x57, 0x56, 0x55, 0x54, 0x53, 0x52, 0x51, 0x50, 0x4f, 0x4e, 0x4d, 0x4c, 0x4b, 0x4a, 0x49, 0x48, 0x47, 0x2c, 0x45, 0x44, 0x43, 0x42, 0x41, 0x40, 0x3f, 0x3e, 0x3d, 0x3c, 0x3b, 0x3a, 0x39, 0x38, 0x13, 0x36, 0x35, 0x34, 0x33, 0x32, 0x31, 0x30, 0x2f, 0x2e, 0x2d, 0x5d, 0x2b, 0x2a, 0x29, 0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21, 0x20, 0x1f, 0x1e, 0x1d, 0x1c, 0x1b, 0x1a, 0x19, 0x18, 0x17, 0x16, 0x15, 0x14, 0x0c, 0x12, 0x11, 0x10, 0x0f, 0x0e, 0x0d, 0x00, 0x0b, 0x0a, 0x09, 0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0x37])),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/631d3938/tv-player-ias.vflset/tv-player-ias.js")!, input: Self.utf8RangeString(0x00...0x66), output: Self.utf8String([0x19, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x00, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63])),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/631d3938/tv-player-es6.vflset/tv-player-es6.js")!, input: Self.utf8RangeString(0x00...0x66), output: Self.utf8String([0x19, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x00, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63])),
    ])
    func signatureForPlayerURL(_ request: SignaturePlayerRequest) async throws {
        let js = try await downloadJavascript(fromURL: request.playerURL)
        let signatureSolver = try SignatureSolver(js: js)
        let inputs = request.pairs.map { $0.input }
        let response = try signatureSolver.batchSolve(request: SignatureSolver.SolveRequest(nInputs: [], sigInputs: inputs))
        for pair in request.pairs {
            let calculatedSignature = try #require(response.sigMap[pair.input])
            #expect(calculatedSignature == pair.output)
        }
    }

}
#endif
