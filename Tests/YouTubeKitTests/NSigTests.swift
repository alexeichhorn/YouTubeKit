//
//  NSigTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 12.06.2025.
//

#if canImport(JavaScriptCore)
import Testing
import Foundation
@testable import YouTubeKit

struct NSigTests {
    
    struct NSigPlayerRequest: CustomTestStringConvertible {
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
    
    @Test("NSig (LegacyCipher) over all players", arguments: [
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/7862ca1f/player_ias.vflset/en_US/base.js")!, input: "X_LCxVDjAavgE5t", output: "yxJ1dM6iz5ogUg"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/9216d1f7/player_ias.vflset/en_US/base.js")!, input: "SLp9F5bwjAdhE9F-", output: "gWnb9IK2DJ8Q1w"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/f8cb7a3b/player_ias.vflset/en_US/base.js")!, input: "oBo2h5euWy6osrUt", output: "ivXHpm7qJjJN"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/2dfe380c/player_ias.vflset/en_US/base.js")!, input: "oBo2h5euWy6osrUt", output: "3DIBbn3qdQ"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/f1ca6900/player_ias.vflset/en_US/base.js")!, input: "cu3wyu6LQn2hse", output: "jvxetvmlI9AN9Q"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8040e515/player_ias.vflset/en_US/base.js")!, input: "wvOFaY-yjgDuIEg5", output: "HkfBFDHmgw4rsw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e06dea74/player_ias.vflset/en_US/base.js")!, input: "AiuodmaDDYw8d3y4bf", output: "ankd8eza2T6Qmw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5dd88d1d/player-plasma-ias-phone-en_US.vflset/base.js")!, input: "kSxKFLeqzv_ZyHSAt", output: "n8gS8oRlHOxPFA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/324f67b9/player_ias.vflset/en_US/base.js")!, input: "xdftNy7dh9QGnhW", output: "22qLGxrmX8F1rA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4c3f79c5/player_ias.vflset/en_US/base.js")!, input: "TDCstCG66tEAO5pR9o", output: "dbxNtZ14c-yWyw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/c81bbb4a/player_ias.vflset/en_US/base.js")!, input: "gre3EcLurNY2vqp94", output: "Z9DfGxWP115WTg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/1f7d5369/player_ias.vflset/en_US/base.js")!, input: "batNX7sYqIJdkJ", output: "IhOkL_zxbkOZBw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/009f1d77/player_ias.vflset/en_US/base.js")!, input: "5dwFHw8aFWQUQtffRq", output: "audescmLUzI3jw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/dc0c6770/player_ias.vflset/en_US/base.js")!, input: "5EHDMgYLV6HPGk_Mu-kk", output: "n9lUJLHbxUI0GQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/113ca41c/player_ias.vflset/en_US/base.js")!, input: "cgYl-tlYkhjT7A", output: "hI7BBr2zUgcmMg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/c57c113c/player_ias.vflset/en_US/base.js")!, input: "M92UUMHa8PdvPd3wyM", output: "3hPqLJsiNZx7yA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5a3b6271/player_ias.vflset/en_US/base.js")!, input: "B2j7f_UPT4rfje85Lu_e", output: "m5DmNymaGQ5RdQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/7a062b77/player_ias.vflset/en_US/base.js")!, input: "NRcE3y3mVtm_cV-W", output: "VbsCYUATvqlt5w"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/dac945fd/player_ias.vflset/en_US/base.js")!, input: "o8BkRxXhuYsBCWi6RplPdP", output: "3Lx32v_hmzTm6A"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/6f20102c/player_ias.vflset/en_US/base.js")!, input: "lE8DhoDmKqnmJJ", output: "pJTTX6XyJP2BYw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/cfa9e7cb/player_ias.vflset/en_US/base.js")!, input: "aCi3iElgd2kq0bxVbQ", output: "QX1y8jGb2IbZ0w"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8c7583ff/player_ias.vflset/en_US/base.js")!, input: "1wWCVpRR96eAmMI87L", output: "KSkWAVv1ZQxC3A"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/b7910ca8/player_ias.vflset/en_US/base.js")!, input: "_hXMCwMt9qE310D", output: "LoZMgkkofRMCZQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/590f65a6/player_ias.vflset/en_US/base.js")!, input: "1tm7-g_A9zsI8_Lay_", output: "xI4Vem4Put_rOg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/b22ef6e7/player_ias.vflset/en_US/base.js")!, input: "b6HcntHGkvBLk_FRf", output: "kNPW6A7FyP2l8A"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3400486c/player_ias.vflset/en_US/base.js")!, input: "lL46g3XifCKUZn1Xfw", output: "z767lhet6V2Skl"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20dfca59/player_ias.vflset/en_US/base.js")!, input: "-fLCxedkAk4LUTK2", output: "O8kfRq1y1eyHGw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/b12cc44b/player_ias.vflset/en_US/base.js")!, input: "keLa5R2U00sR9SQK", output: "N1OGyujjEwMnLw"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3bb1f723/player_ias.vflset/en_US/base.js")!, input: "gK15nzVyaXE9RsMP3z", output: "ZFFWFLPWx9DEgQ"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/2f1832d2/player_ias.vflset/en_US/base.js")!, input: "YWt1qdbe8SAfkoPHW5d", output: "RrRjWQOJmBiP"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/9c6dfc4a/player_ias.vflset/en_US/base.js")!, input: "jbu7ylIosQHyJyJV", output: "uwI0ESiynAmhNg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e7567ecf/player_ias_tce.vflset/en_US/base.js")!, input: "Sy4aDGc0VpYRR9ew_", output: "5UPOT1VhoZxNLQ"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/d50f54ef/player_ias_tce.vflset/en_US/base.js")!, input: "Ha7507LzRmH3Utygtj", output: "XFTb2HoeOE5MHg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/074a8365/player_ias_tce.vflset/en_US/base.js")!, input: "Ha7507LzRmH3Utygtj", output: "ufTsrE0IVYrkl8v"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/643afba4/player_ias.vflset/en_US/base.js")!, input: "N5uAlLqm0eg1GyHO", output: "dCBQOejdq5s-ww"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/69f581a5/tv-player-ias.vflset/tv-player-ias.js")!, input: "-qIP447rVlTTwaZjY", output: "KNcGOksBAvwqQg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/643afba4/tv-player-ias.vflset/tv-player-ias.js")!, input: "ir9-V6cdbCiyKxhr", output: "2PL7ZDYAALMfmA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/363db69b/player_ias.vflset/en_US/base.js")!, input: "eWYu5d5YeY_4LyEDc", output: "XJQqf-N7Xra3gg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias.vflset/en_US/base.js")!, input: "o_L251jm8yhZkWtBW", output: "lXoxI3XvToqn6A"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias_tce.vflset/en_US/base.js")!, input: "o_L251jm8yhZkWtBW", output: "lXoxI3XvToqn6A"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/tv-player-ias.vflset/tv-player-ias.js")!, input: "ir9-V6cdbCiyKxhr", output: "9YE85kNjZiS4"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-phone-en_US.vflset/base.js")!, input: "ir9-V6cdbCiyKxhr", output: "9YE85kNjZiS4"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-tablet-en_US.vflset/base.js")!, input: "ir9-V6cdbCiyKxhr", output: "9YE85kNjZiS4"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/player_ias_tce.vflset/en_US/base.js")!, input: "MiBYeXx_vRREbiCCmh", output: "RtZYMVvmkE0JE"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/tv-player-es6.vflset/tv-player-es6.js")!, input: "MiBYeXx_vRREbiCCmh", output: "RtZYMVvmkE0JE"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/59b252b9/player_ias.vflset/en_US/base.js")!, input: "D3XWVpYgwhLLKNK4AGX", output: "aZrQ1qWJ5yv5h"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/fc2a56a5/player_ias.vflset/en_US/base.js")!, input: "qTKWg_Il804jd2kAC", output: "OtUAm2W6gyzJjB9u"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/fc2a56a5/tv-player-ias.vflset/tv-player-ias.js")!, input: "qTKWg_Il804jd2kAC", output: "OtUAm2W6gyzJjB9u"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/a74bf670/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "hQP7k1hA22OrNTnq"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/6275f73c/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "-I03XF0iyf6I_X0A"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20c72c18/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "-I03XF0iyf6I_X0A"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/9fe2e06e/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "6r5ekNIiEMPutZy"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/680f8c75/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "0ml9caTwpa55Jf"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/14397202/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "ozZFAN21okDdJTa"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5dcb2c1f/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "p7iTbRZDYAF"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/a10d7fcc/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "9Zue7DDHJSD"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8e20cb06/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "5-4tTneTROTpMzba"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e12fbea4/player_ias_tce.vflset/en_US/base.js")!, input: "kM5r52fugSZRAKHfo3", output: "XkeRfXIPOkSwfg"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/ef259203/player_ias_tce.vflset/en_US/base.js")!, input: "rPqBC01nJpqhhi2iA2U", output: "hY7dbiKFT51UIA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/010fbc8d/player_es5.vflset/en_US/base.js")!, input: "0hlOAlqjFszVvF4Z", output: "R-H23bZGAsRFTg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/010fbc8d/player_es6.vflset/en_US/base.js")!, input: "0hlOAlqjFszVvF4Z", output: "R-H23bZGAsRFTg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5ec65609/player_ias_tcc.vflset/en_US/base.js")!, input: "6l5CTNx4AzIqH4MXM", output: "NupToduxHBew1g"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0004de42/player_ias.vflset/en_US/base.js")!, input: "v4gt0ELCwTyStf7", output: "1shFzRzNdZSddQ"),
    ])
    func nSigLegacyForPlayerURL(_ request: NSigPlayerRequest) async throws {
        let js = try await downloadJavascript(fromURL: request.playerURL)
        let cipher = try Cipher(js: js)
        for pair in request.pairs {
            let calculatedN = try cipher.calculateN(initialN: pair.input)
            #expect(calculatedN == pair.output)
        }
    }
    
    
    @Test("NSig over all players", arguments: [
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e06dea74/player_ias.vflset/en_US/base.js")!, input: "AiuodmaDDYw8d3y4bf", output: "ankd8eza2T6Qmw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5dd88d1d/player-plasma-ias-phone-en_US.vflset/base.js")!, input: "kSxKFLeqzv_ZyHSAt", output: "n8gS8oRlHOxPFA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/324f67b9/player_ias.vflset/en_US/base.js")!, input: "xdftNy7dh9QGnhW", output: "22qLGxrmX8F1rA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4c3f79c5/player_ias.vflset/en_US/base.js")!, input: "TDCstCG66tEAO5pR9o", output: "dbxNtZ14c-yWyw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/c81bbb4a/player_ias.vflset/en_US/base.js")!, input: "gre3EcLurNY2vqp94", output: "Z9DfGxWP115WTg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/1f7d5369/player_ias.vflset/en_US/base.js")!, input: "batNX7sYqIJdkJ", output: "IhOkL_zxbkOZBw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/009f1d77/player_ias.vflset/en_US/base.js")!, input: "5dwFHw8aFWQUQtffRq", output: "audescmLUzI3jw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/dc0c6770/player_ias.vflset/en_US/base.js")!, input: "5EHDMgYLV6HPGk_Mu-kk", output: "n9lUJLHbxUI0GQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/113ca41c/player_ias.vflset/en_US/base.js")!, input: "cgYl-tlYkhjT7A", output: "hI7BBr2zUgcmMg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/c57c113c/player_ias.vflset/en_US/base.js")!, input: "M92UUMHa8PdvPd3wyM", output: "3hPqLJsiNZx7yA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5a3b6271/player_ias.vflset/en_US/base.js")!, input: "B2j7f_UPT4rfje85Lu_e", output: "m5DmNymaGQ5RdQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/7a062b77/player_ias.vflset/en_US/base.js")!, input: "NRcE3y3mVtm_cV-W", output: "VbsCYUATvqlt5w"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/dac945fd/player_ias.vflset/en_US/base.js")!, input: "o8BkRxXhuYsBCWi6RplPdP", output: "3Lx32v_hmzTm6A"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/6f20102c/player_ias.vflset/en_US/base.js")!, input: "lE8DhoDmKqnmJJ", output: "pJTTX6XyJP2BYw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/cfa9e7cb/player_ias.vflset/en_US/base.js")!, input: "aCi3iElgd2kq0bxVbQ", output: "QX1y8jGb2IbZ0w"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8c7583ff/player_ias.vflset/en_US/base.js")!, input: "1wWCVpRR96eAmMI87L", output: "KSkWAVv1ZQxC3A"),
        //NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/b7910ca8/player_ias.vflset/en_US/base.js")!, input: "_hXMCwMt9qE310D", output: "LoZMgkkofRMCZQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/590f65a6/player_ias.vflset/en_US/base.js")!, input: "1tm7-g_A9zsI8_Lay_", output: "xI4Vem4Put_rOg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/b22ef6e7/player_ias.vflset/en_US/base.js")!, input: "b6HcntHGkvBLk_FRf", output: "kNPW6A7FyP2l8A"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3400486c/player_ias.vflset/en_US/base.js")!, input: "lL46g3XifCKUZn1Xfw", output: "z767lhet6V2Skl"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20dfca59/player_ias.vflset/en_US/base.js")!, input: "-fLCxedkAk4LUTK2", output: "O8kfRq1y1eyHGw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/b12cc44b/player_ias.vflset/en_US/base.js")!, input: "keLa5R2U00sR9SQK", output: "N1OGyujjEwMnLw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3bb1f723/player_ias.vflset/en_US/base.js")!, input: "gK15nzVyaXE9RsMP3z", output: "ZFFWFLPWx9DEgQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/2f1832d2/player_ias.vflset/en_US/base.js")!, input: "YWt1qdbe8SAfkoPHW5d", output: "RrRjWQOJmBiP"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/9c6dfc4a/player_ias.vflset/en_US/base.js")!, input: "jbu7ylIosQHyJyJV", output: "uwI0ESiynAmhNg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/e7567ecf/player_ias_tce.vflset/en_US/base.js")!, input: "Sy4aDGc0VpYRR9ew_", output: "5UPOT1VhoZxNLQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/d50f54ef/player_ias_tce.vflset/en_US/base.js")!, input: "Ha7507LzRmH3Utygtj", output: "XFTb2HoeOE5MHg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/074a8365/player_ias_tce.vflset/en_US/base.js")!, input: "Ha7507LzRmH3Utygtj", output: "ufTsrE0IVYrkl8v"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/643afba4/player_ias.vflset/en_US/base.js")!, input: "N5uAlLqm0eg1GyHO", output: "dCBQOejdq5s-ww"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/69f581a5/tv-player-ias.vflset/tv-player-ias.js")!, input: "-qIP447rVlTTwaZjY", output: "KNcGOksBAvwqQg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/643afba4/tv-player-ias.vflset/tv-player-ias.js")!, input: "ir9-V6cdbCiyKxhr", output: "2PL7ZDYAALMfmA"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/363db69b/player_ias.vflset/en_US/base.js")!, input: "eWYu5d5YeY_4LyEDc", output: "XJQqf-N7Xra3gg"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias.vflset/en_US/base.js")!, input: "o_L251jm8yhZkWtBW", output: "lXoxI3XvToqn6A"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/4fcd6e4a/player_ias_tce.vflset/en_US/base.js")!, input: "o_L251jm8yhZkWtBW", output: "lXoxI3XvToqn6A"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/tv-player-ias.vflset/tv-player-ias.js")!, input: "ir9-V6cdbCiyKxhr", output: "9YE85kNjZiS4"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-phone-en_US.vflset/base.js")!, input: "ir9-V6cdbCiyKxhr", output: "9YE85kNjZiS4"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/20830619/player-plasma-ias-tablet-en_US.vflset/base.js")!, input: "ir9-V6cdbCiyKxhr", output: "9YE85kNjZiS4"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/player_ias_tce.vflset/en_US/base.js")!, input: "MiBYeXx_vRREbiCCmh", output: "RtZYMVvmkE0JE"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/8a8ac953/tv-player-es6.vflset/tv-player-es6.js")!, input: "MiBYeXx_vRREbiCCmh", output: "RtZYMVvmkE0JE"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/59b252b9/player_ias.vflset/en_US/base.js")!, input: "D3XWVpYgwhLLKNK4AGX", output: "aZrQ1qWJ5yv5h"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/fc2a56a5/player_ias.vflset/en_US/base.js")!, input: "qTKWg_Il804jd2kAC", output: "OtUAm2W6gyzJjB9u"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/fc2a56a5/tv-player-ias.vflset/tv-player-ias.js")!, input: "qTKWg_Il804jd2kAC", output: "OtUAm2W6gyzJjB9u"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/0004de42/player_ias.vflset/en_US/base.js")!, input: "v4gt0ELCwTyStf7", output: "1shFzRzNdZSddQ"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/3d3ba064/player_ias_tce.vflset/en_US/base.js")!, pairs: [
            NSigPlayerRequest.Pair(input: "ZdZIqFPQK-Ty8wId", output: "qmtUsIz04xxiNW"),
            NSigPlayerRequest.Pair(input: "4GMrWHyKI5cEvhDO", output: "N9gmEX7YhKTSmw")
        ]),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/5ec65609/player_ias_tce.vflset/en_US/base.js")!, input: "0eRGgQWJGfT5rFHFj", output: "4SvMpDQH-vBJCw"),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/6742b2b9/player_ias_tce.vflset/en_US/base.js")!, pairs: [
            NSigPlayerRequest.Pair(input: "_HPB-7GFg1VTkn9u", output: "qUAsPryAO_ByYg"),
            NSigPlayerRequest.Pair(input: "K1t_fcB6phzuq2SF", output: "Y7PcOt3VE62mog")
        ]),
        NSigPlayerRequest(playerURL: URL(string: "https://www.youtube.com/s/player/c1c87fb0/player_ias_tce.vflset/en_US/base.js")!, input: "ZdZIqFPQK-Ty8wId", output: "jCHBK5GuAFNa2"),
    ])
    func nSigForPlayerURL(_ request: NSigPlayerRequest) async throws {
        let js = try await downloadJavascript(fromURL: request.playerURL)
        let signatureSolver = try SignatureSolver(js: js)
        let inputs = request.pairs.map { $0.input }
        let response = try signatureSolver.batchSolve(request: SignatureSolver.SolveRequest(nInputs: inputs, sigInputs: []))
        for pair in request.pairs {
            let calculatedN = try #require(response.nMap[pair.input])
            #expect(calculatedN == pair.output)
        }
    }
    
}

#endif
