//
//  SignatureTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 12.06.2025.
//

import Testing
import Foundation
@testable import YouTubeKit

struct SignatureTests {

    struct SignaturePlayerRequest: CustomTestStringConvertible {
        let playerURL: URL
        let input: String
        let output: String

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

    @Test("Signature over all players", arguments: [
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/6ed0d907/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "AOq0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xx8j7v1pDL2QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3bb1f723/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "MyOSJXtKI3m-uME_jv7-pT12gOFC02RFkGoqWpzE0Cs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/2f1832d2/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xxAj7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJ2OySqa0q"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/643afba4/tv-player-ias.vflset/tv-player-ias.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "AAOAOq0QJ8wRAIgXmPlOPSBkkUs1bYFYlJCfe29xx8j7vgpDL0QwbdV06sCIEzpWqMGkFR20CFOS21Tp-7vj_EMu-m37KtXJoOy1"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/363db69b/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpz2ICs6EVdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/363db69b/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpz2ICs6EVdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "wAOAOq0QJ8ARAIgXmPlOPSBkkUs1bYFYlJCfe29xx8q7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "wAOAOq0QJ8ARAIgXmPlOPSBkkUs1bYFYlJCfe29xx8q7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-phone-en_US.vflset/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "7AOq0QJ8wRAIgXmPlOPSBkkAs1bYFYlJCfe29xx8jOv1pDL0Q2bdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_EMu-m37KtXJoOySqa0qaw"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/player_ias_tce.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "IAOAOq0QJ8wRAAgXmPlOPSBkkUs1bYFYlJCfe29xx8j7v1pDL0QwbdV96sCIEzpWqMGkFR20CFOg51Tp-7vj_E2u-m37KtXJoOySqa0"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e12fbea4/player_ias.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "JC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEvaepit0zJAtIEsgOV2SXZjhSHMNy0NXNG_1kOyBf6HPuAuCduh-a"),
//        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/010fbc8d/player_es5.vflset/en_US/base.js")!, input: "gN7a-hudCuAuPH6fByOk1_GNXN0yNMHShjZXS2VOgsEItAJz0tipeavEOmNdYN-wUtcEqD3bCXjc0iyKfAyZxCBGgIARwsSdQfJ2CJtt", output: "ttJC2JfQdSswRAIgGBCxZyAfKyi0cjXCb3DqEctUw-NYdNmOEvaepit2zJAsIEggOVaSXZjhSHMNy0NXNG_1kOyBf6HPuAuCduh-"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5ec65609/player_ias_tcc.vflset/en_US/base.js")!, input: "AAJAJfQdSswRAIgNSN0GDUcHnCIXkKcF61yLBgDHiX1sUhOJdY4_GxunRYCIDeYNYP_16mQTPm5f1OVq3oV1ijUNYPjP4iUSMAjO9bZ", output: "AJfQdSswRAIgNSN0GDUcHnCIXkKcF61ZLBgDHiX1sUhOJdY4_GxunRYCIDyYNYP_16mQTPm5f1OVq3oV1ijUNYPjP4iUSMAjO9be"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0004de42/player_ias.vflset/en_US/base.js")!, input: "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA", output: "0aqSyOoJXtK73m-uME_jv2-pT15gOFC02R7kGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qO"),
        SignaturePlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0004de42/player_ias.vflset/en_US/base.js")!, input: "kJfAJfQdSswRgIhAIAVJyVrl-q9IeaMXTX9wuANotEnc3R9lQfdVaMFLa01AiEApmr1KuBrdE__Tc_p6_7QFuQI-arti18Yg1-Ac7xfjkg=kg==", output: "AJfQdSswRgIhAIAVJyVrlkq9IeaMXTX9wu-NotEnc3R9lQfdVaMFLa01AiEApmr1KuBrdE__Tc_p6_7QFuQI-arti18Yg1-Ac7xfjkg=")
    ])
    func signatureForPlayerURL(_ request: SignaturePlayerRequest) async throws {
        let js = try await downloadJavascript(fromURL: request.playerURL)
        let cipher = try Cipher(js: js)
        let calculatedSignature = cipher.getSignature(cipheredSignature: request.input)
        #expect(calculatedSignature == request.output)
    }

}
