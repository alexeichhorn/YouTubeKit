import XCTest
@testable import YouTubeKit

@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
final class YouTubeKitTests: XCTestCase {
    
    func testVideoUnavailable() async {
        let youtube = YouTube(videoID: "cTsNJNx7plQ")
        do {
            try await youtube.checkAvailability()
            XCTFail("Expected throw")
        } catch let error {
            XCTAssertEqual(error as? YouTubeKitError, .videoPrivate)
        }
    }
    
    func testVideoAvailable() async {
        let youtube = YouTube(videoID: "9bZkp7q19f0")
        do {
            try await youtube.checkAvailability()
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testSampleVideo1() async {
        let youtube = YouTube(videoID: "9bZkp7q19f0")
        do {
            let streams = try await youtube.streams
            XCTAssert(streams.count > 0)
            checkStreams(streams)
            
            let bestAudioStreamLegacy = streams.filterAudioOnly().filter { $0.subtype == "mp4" }.highestAudioBitrateStream()
            let bestAudioStream = streams.filterAudioOnly().filter { $0.fileExtension == .m4a }.highestAudioBitrateStream()
            print(bestAudioStream)
            
            XCTAssert(!streams.filterVideoOnly().isEmpty)
            XCTAssert(!streams.filterAudioOnly().isEmpty)
            XCTAssert(!streams.filterVideoAndAudio().isEmpty)
            
            XCTAssertEqual(bestAudioStream?.url, bestAudioStreamLegacy?.url)
            
            try await checkAllStreamReachability(streams)
            
            // test Cipher initialization directly (in case not lazily loaded)
            await XCTAssertNoThrow(try await Cipher(js: youtube.js), "Failed to initialize Cipher")
            
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testSampleVideo2() async {
        let youtube = YouTube(videoID: "2lAe1cqCOXo")
        do {
            let streams = try await youtube.streams
            XCTAssert(streams.count > 0)
            checkStreams(streams)
            print(streams)
            print(streams.count)
            //print(streams.filterAudioOnly().filter { $0.subtype == "mp4" }.highestAudioBitrateStream()?.url)
            print(streams.filterVideoOnly().highestResolutionStream())
            
            XCTAssert(!streams.filterVideoOnly().isEmpty)
            XCTAssert(!streams.filterAudioOnly().isEmpty)
            XCTAssert(!streams.filterVideoAndAudio().isEmpty)
            
            try await checkAllStreamReachability(streams)
            
            // test Cipher initialization directly (in case not lazily loaded)
            await XCTAssertNoThrow(try await Cipher(js: youtube.js), "Failed to initialize Cipher")
            
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testSampleVideo3() async {
        let youtube = YouTube(videoID: "dkpDjd2nHgo", methods: [.remote])
        do {
            let streams = try await youtube.streams
            XCTAssert(streams.count > 0)
            checkStreams(streams)
            print(streams)
            print(streams.count)
            //print(streams.filterAudioOnly().filter { $0.subtype == "mp4" }.highestAudioBitrateStream()?.url)
            //print(streams.filterVideoOnly().highestResolutionStream())
            print(streams.filter { $0.isProgressive && $0.fileExtension == .mp4 }.lowestResolutionStream()!)
            
            XCTAssert(!streams.filterVideoOnly().isEmpty)
            XCTAssert(!streams.filterAudioOnly().isEmpty)
            XCTAssert(!streams.filterVideoAndAudio().isEmpty)
            
            try await checkAllStreamReachability(streams)
            
            // test Cipher initialization directly (in case not lazily loaded)
            await XCTAssertNoThrow(try await Cipher(js: youtube.js), "Failed to initialize Cipher")
            
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testSampleVideo4() async {
        let youtube = YouTube(videoID: "NOid0U6GxUA") // non-music video
        do {
            let streams = try await youtube.streams
            XCTAssert(streams.count > 0)
            checkStreams(streams)
            print(streams)
            print(streams.count)
            //print(streams.filterAudioOnly().filter { $0.subtype == "mp4" }.highestAudioBitrateStream()?.url)
            print(streams.filterVideoOnly().highestResolutionStream())
            
            XCTAssert(!streams.filterVideoOnly().isEmpty)
            XCTAssert(!streams.filterAudioOnly().isEmpty)
            XCTAssert(!streams.filterVideoAndAudio().isEmpty)
            
            try await checkAllStreamReachability(streams)
            
            // test Cipher initialization directly (in case not lazily loaded)
            await XCTAssertNoThrow(try await Cipher(js: youtube.js), "Failed to initialize Cipher")
            
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testSampleVideo5() async {
        let youtube = YouTube(videoID: "ObUBUKOn-bo")
        do {
            let streams = try await youtube.streams
            XCTAssert(streams.count > 0)
            checkStreams(streams)
            
            XCTAssert(!streams.filterVideoOnly().isEmpty)
            XCTAssert(!streams.filterAudioOnly().isEmpty)
            XCTAssert(!streams.filterVideoAndAudio().isEmpty)
            
            try await checkAllStreamReachability(streams)
            
            // test Cipher initialization directly (in case not lazily loaded)
            await XCTAssertNoThrow(try await Cipher(js: youtube.js), "Failed to initialize Cipher")
            
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testSampleVideoAgeRestricted() async {
        let youtube = YouTube(videoID: "HtVdAasjOgU") // EX_8ZjT2sO4
        do {
            let streams = try await youtube.streams
            XCTAssert(streams.count > 0)
            checkStreams(streams)
            print(streams.count)
            //print(streams.filterAudioOnly().filter { $0.subtype == "mp4" }.highestAudioBitrateStream()?.url)
            print(streams.filter { $0.isProgressive }.highestResolutionStream())
            
            XCTAssert(!streams.filterVideoOnly().isEmpty)
            XCTAssert(!streams.filterAudioOnly().isEmpty)
            XCTAssert(!streams.filterVideoAndAudio().isEmpty)
            
            try await checkAllStreamReachability(streams)
            
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testLivestreamHlsManifestUrl() async {
        let youtube = YouTube(videoID: "wG4YaEcNlb0")
        do {
            let livestreams = try await youtube.livestreams
            XCTAssert(livestreams.count > 0)
            
            let hlsURL = livestreams.filter { $0.streamType == .hls }.first?.url
            XCTAssertTrue(hlsURL!.absoluteString.contains(".m3u8"))
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testLivestreamHlsManifestUrlRemote() async {
        let youtube = YouTube(videoID: "wG4YaEcNlb0", methods: [.remote])
        do {
            let livestreams = try await youtube.livestreams
            XCTAssert(livestreams.count > 0)
            
            let hlsURL = livestreams.filter { $0.streamType == .hls }.first?.url
            XCTAssertTrue(hlsURL!.absoluteString.contains(".m3u8"))
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testRemoteExtraction() async {
        let youtube = YouTube(videoID: "2lAe1cqCOXo", methods: [.remote])
        do {
            let streams = try await youtube.streams
            XCTAssert(streams.count > 0)
            checkStreams(streams)
            print(streams.count)
            
            XCTAssert(!streams.filterVideoOnly().isEmpty)
            XCTAssert(!streams.filterAudioOnly().isEmpty)
            XCTAssert(!streams.filterVideoAndAudio().isEmpty)
            
            try await checkAllStreamReachability(streams)
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    // MARK: - Metadata
    
    func testMetadataForOnDemand() async {
        let youtube = YouTube(videoID: "ApM_KEr1ktQ")
        do {
            let metadata = try await youtube.metadata!
            XCTAssertEqual(metadata.title, "Le Maroc Vu du Ciel (Documentaire de Yann Arthus-Bertrand)")
            XCTAssertFalse(metadata.description.isEmpty)
            XCTAssert([URL(string: "https://i.ytimg.com/vi/ApM_KEr1ktQ/sddefault.jpg")!, URL(string: "https://i.ytimg.com/vi/ApM_KEr1ktQ/hqdefault.jpg")!].contains(metadata.thumbnail!.url))
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testMetadataForOnDemandWithRemote() async {
        let youtube = YouTube(videoID: "ApM_KEr1ktQ", methods: [.remote])
        do {
            let metadata = try await youtube.metadata!
            XCTAssertEqual(metadata.title, "Le Maroc Vu du Ciel (Documentaire de Yann Arthus-Bertrand)")
            XCTAssertFalse(metadata.description.isEmpty)
            XCTAssert([URL(string: "https://i.ytimg.com/vi/ApM_KEr1ktQ/sddefault.jpg")!, URL(string: "https://i.ytimg.com/vi/ApM_KEr1ktQ/hqdefault.jpg")!].contains(metadata.thumbnail!.url))
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    
    func testMetadataForLive() async {
        let youtube = YouTube(videoID: "Z-Nwo-ypKtM")
        do {
            let metadata = try await youtube.metadata!
            XCTAssertEqual(metadata.title, "franceinfo - DIRECT TV - actualité france et monde, interviews, documentaires et analyses")
            XCTAssertFalse(metadata.description.isEmpty)
            XCTAssertNotNil(metadata.thumbnail!.url)
        } catch let error {
            XCTFail("did throw error: \(error)")
        }
    }
    

    // MARK: - Performance Measurement
    
    func testObjectParsingFromStartpoint() {
        let expectedResult = #"[{"_id":"6135f0e3862c83ea7bdd6f53","index":0,"guid":"a4b4d889-126f-4b39-a8e8-eb0edfef41ab","isActive":false,"balance":"$3,423.96","picture":"http://placehold.it/32x32","age":32,"eyeColor":"green","name":"Hale Serrano","gender":"male","company":"ROCKYARD","email":"haleserrano@rockyard.com","phone":"+1 (828) 442-2210","address":"852 Strong Place, Ribera, Palau, 4121","about":"Ex ad voluptate enim Lorem mollit commodo. Et ullamco veniam nisi deserunt sint reprehenderit. Eiusmod sint nostrud cillum est deserunt aliquip culpa nulla reprehenderit. Eiusmod consectetur ad non ipsum cupidatat aute elit est laborum amet dolor Lorem. Pariatur consectetur nulla mollit officia ex quis velit ad laboris voluptate amet cupidatat eu. Aliqua cupidatat id magna exercitation laborum pariatur non proident pariatur aute sit exercitation nulla. Dolor officia tempor nisi laboris.\r\n","registered":"2017-02-24T09:37:32 -01:00","latitude":-77.879904,"longitude":108.045011,"tags":["qui","occaecat","cillum","aliqua","culpa","laborum","laboris"],"friends":[{"id":0,"name":"Burt Gates"},{"id":1,"name":"Burgess Horn"},{"id":2,"name":"Waller Durham"}],"greeting":"Hello, Hale Serrano! You have 6 unread messages.","favoriteFruit":"banana"},{"_id":"6135f0e38de05010d150403d","index":1,"guid":"52599b0c-d4dc-4765-991f-7a858d84e8a1","isActive":true,"balance":"$3,667.24","picture":"http://placehold.it/32x32","age":34,"eyeColor":"brown","name":"Della Wheeler","gender":"female","company":"BLURRYBUS","email":"dellawheeler@blurrybus.com","phone":"+1 (947) 521-3090","address":"139 Auburn Place, Oretta, Idaho, 2267","about":"Labore esse dolor sit anim minim pariatur voluptate sint aliqua. Quis exercitation ex dolor aliquip minim laborum enim cillum. Exercitation officia cupidatat ex exercitation amet incididunt dolore consectetur veniam quis velit minim pariatur enim. Nostrud cillum id ullamco ipsum eiusmod laboris ipsum cupidatat adipisicing in minim voluptate est in.\r\n","registered":"2019-01-29T06:02:19 -01:00","latitude":86.649992,"longitude":80.833842,"tags":["exercitation","officia","et","est","deserunt","qui","quis"],"friends":[{"id":0,"name":"Watson Kaufman"},{"id":1,"name":"Adriana Dale"},{"id":2,"name":"Miles Barber"}],"greeting":"Hello, Della Wheeler! You have 3 unread messages.","favoriteFruit":"strawberry"},{"_id":"6135f0e33b39f3abb3815675","index":2,"guid":"e654c0e4-25aa-48f7-b553-2e949b30106a","isActive":true,"balance":"$1,626.33","picture":"http://placehold.it/32x32","age":39,"eyeColor":"blue","name":"Nielsen Carpenter","gender":"male","company":"SPORTAN","email":"nielsencarpenter@sportan.com","phone":"+1 (891) 567-3952","address":"157 Hudson Avenue, Chumuckla, North Carolina, 3021","about":"Minim enim laborum nulla aliqua commodo reprehenderit excepteur. Ut eu esse nisi ea dolor occaecat eiusmod amet dolor. Nisi Lorem sint eu voluptate nisi dolore laboris excepteur aliqua velit. Incididunt reprehenderit ex irure dolore et laborum ad nulla incididunt incididunt exercitation sint. Nulla Lorem ea officia consequat eu veniam tempor labore incididunt commodo consectetur aliquip.\r\n","registered":"2017-02-24T08:40:43 -01:00","latitude":89.65141,"longitude":76.569564,"tags":["proident","culpa","voluptate","eiusmod","incididunt","adipisicing","ullamco"],"friends":[{"id":0,"name":"Sheila Mcintyre"},{"id":1,"name":"Chapman Spence"},{"id":2,"name":"Minnie Frederick"}],"greeting":"Hello, Nielsen Carpenter! You have 2 unread messages.","favoriteFruit":"apple"},{"_id":"6135f0e35b4aa8c3f9700f5f","index":3,"guid":"5b16e91b-11c5-4d59-8b55-4d9412c19924","isActive":false,"balance":"$2,385.85","picture":"http://placehold.it/32x32","age":39,"eyeColor":"green","name":"Sparks Roman","gender":"male","company":"ECRATIC","email":"sparksroman@ecratic.com","phone":"+1 (850) 452-2236","address":"150 Anthony Street, Rockbridge, Illinois, 9942","about":"Aute aliqua exercitation commodo cillum velit voluptate. Non ex Lorem id exercitation do aute aute sint ipsum reprehenderit adipisicing. Anim eu exercitation sint officia ullamco ut. Consectetur fugiat quis ex pariatur incididunt sit duis magna non aute incididunt nostrud.\r\n","registered":"2014-07-03T09:56:19 -02:00","latitude":23.386985,"longitude":-155.463398,"tags":["et","tempor","enim","exercitation","do","adipisicing","quis"],"friends":[{"id":0,"name":"Bell Barker"},{"id":1,"name":"Dorothy Castro"},{"id":2,"name":"Kim Schmidt"}],"greeting":"Hello, Sparks Roman! You have 6 unread messages.","favoriteFruit":"banana"},{"_id":"6135f0e35ba27305bba3e7e0","index":4,"guid":"a4763aaa-715b-4ad1-b849-1c2fc57fd14c","isActive":false,"balance":"$1,502.86","picture":"http://placehold.it/32x32","age":35,"eyeColor":"green","name":"Jenna Donaldson","gender":"female","company":"TRIBALOG","email":"jennadonaldson@tribalog.com","phone":"+1 (985) 514-3580","address":"530 Hutchinson Court, Kidder, Marshall Islands, 6466","about":"In ex pariatur nulla eiusmod labore. Anim minim sint sint exercitation voluptate est nostrud adipisicing in dolor aute aute. Enim pariatur officia enim ad eu non ad consequat ex elit enim. Fugiat exercitation aute mollit adipisicing pariatur ad sunt ut quis enim culpa enim. Mollit ex cillum incididunt aute culpa officia aliqua officia veniam mollit.\r\n","registered":"2016-07-13T10:14:50 -02:00","latitude":-81.921245,"longitude":20.76489,"tags":["consequat","magna","veniam","commodo","qui","voluptate","ex"],"friends":[{"id":0,"name":"Avery Glass"},{"id":1,"name":"Clements Hester"},{"id":2,"name":"Carmella Fleming"}],"greeting":"Hello, Jenna Donaldson! You have 7 unread messages.","favoriteFruit":"apple"},{"_id":"6135f0e34d02e9ca17ba6c5e","index":5,"guid":"4c956d97-d552-4dbc-8832-82b03eb17116","isActive":true,"balance":"$2,047.41","picture":"http://placehold.it/32x32","age":26,"eyeColor":"blue","name":"Turner Singleton","gender":"male","company":"TOYLETRY","email":"turnersingleton@toyletry.com","phone":"+1 (958) 442-3510","address":"637 Schenck Avenue, Waikele, Colorado, 3702","about":"Culpa sit enim esse dolore eiusmod mollit dolore sit magna aute qui velit ea pariatur. Esse sit laborum mollit laboris dolore id proident aliqua fugiat consequat. Irure ea mollit esse tempor sint cillum. Ullamco labore labore ipsum est nulla ea excepteur. Exercitation deserunt culpa deserunt minim aliqua nulla sit reprehenderit sint elit laboris eiusmod ipsum. Reprehenderit est ad occaecat consectetur laboris adipisicing quis officia laboris sunt velit.\r\n","registered":"2017-10-20T05:51:40 -02:00","latitude":44.180915,"longitude":-111.89157,"tags":["mollit","aliqua","exercitation","nulla","nostrud","pariatur","non"],"friends":[{"id":0,"name":"Hickman Holmes"},{"id":1,"name":"Ward Richard"},{"id":2,"name":"Irene Duke"}],"greeting":"Hello, Turner Singleton! You have 4 unread messages.","favoriteFruit":"apple"}]"#
        let baseHTML = expectedResult + #"{"responseContext": {"serviceTrackingParams": [{"service": "GFEEDBACK", "params": [{"key": "is_viewed_live", "value": "False"}, {"key": "logged_in", "value": "0"}, {"key": "e", "value": "23885487,24007790,24079272,24098642,23934970,23966208,24084232,23923339,24056274,24002022,24050503,24049820,23983296,24080738,24087533,23996830,24089919,23975058,24087603,23968386,24046872,23918597,24028143,24002025,24065633,24083164,24082662,1714246,23944779,24077266,24002922,23974595,23998056,23744176,24590540,23897180,23735347,24083448,24058380,24036948,23857949,24083162,24083190,24088877,24089488,24083188,23882502,23884386,24004644,24087223,23804281,24001373,23946420,24037794,24091075,24007246"}]}, {"service": "CSI", "params": [{"key": "yt_ad", "value": "1"}, {"key": "c", "value": "MWEB"}, {"key": "cver", "value": "2.20210903.00.00"}, {"key": "yt_li", "value": "0"}, {"key": "GetPlayer_rid", "value": "0x0080d83149e3113d"}]}, {"service": "ECATCHER", "params": [{"key": "client.version", "value": "2.20210903"}, {"key": "client.name", "value": "MWEB"}]}], "webResponseContextExtensionData": {"hasDecorated": true}}, "playabilityStatus": {"status": "OK", "playableInEmbed": true, "contextParams": "Q0FFU0FnZ0I="}, "streamingData": {"expiresInSeconds": "21540", "formats": [{"itag": 18, "mimeType": "video/mp4; codecs=\"avc1.42001E, mp4a.40.2\"", "bitrate": 708732, "width": 640, "height": 360, "lastModified": "1626250059368059", "contentLength": "22339951", "quality": "medium", "fps": 24, "qualityLabel": "360p", "projectionType": "RECTANGULAR", "averageBitrate": 708471, "audioQuality": "AUDIO_QUALITY_LOW", "approxDurationMs": "252261", "audioSampleRate": "44100", "audioChannels": 2, "signatureCipher"}"#
        measure {
            do {
                let result = try Extraction.findObjectFromStartpoint(html: baseHTML, startPoint: baseHTML.startIndex)
                XCTAssertEqual(result, expectedResult)
            } catch {
                XCTFail()
            }
        }
    }
    
    
    
    // MARK: - Helper Functions
    
    private func checkStreamReachability(_ stream: YouTubeKit.Stream?) async throws {
        guard let stream else { return }
        
        var request = URLRequest(url: stream.url)
        request.httpMethod = "head"
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            XCTAssertEqual(httpResponse.statusCode, 200, "Stream is not reachable (got status code \(httpResponse.statusCode))")
        }
    }
    
    private func isStreamReachable(_ stream: YouTubeKit.Stream?) async throws -> Bool {
        guard let stream else { return false }
        
        var request = URLRequest(url: stream.url)
        request.httpMethod = "head"
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
        
        return false
    }
    
    private func checkAllStreamReachability(_ streams: [YouTubeKit.Stream]) async throws {
        var numNonReachable = 0
        for stream in streams {
            if try await !isStreamReachable(stream) {
                numNonReachable += 1
            }
        }
        XCTAssert(numNonReachable == 0, "\(numNonReachable)/\(streams.count) streams are not reachable")
    }
    
    private func checkStreams(_ streams: [YouTubeKit.Stream]) {
        for stream in streams {
            XCTAssert(stream.videoCodec != nil || stream.audioCodec != nil)
            
            if let videoCodec = stream.videoCodec {
                if case .unknown(_) = videoCodec {
                    XCTFail("Video codec is unknown")
                }
            }
            
            if let audioCodec = stream.audioCodec {
                if case .unknown(_) = audioCodec {
                    XCTFail("Audio codec is unknown")
                }
            }
        }
    }
    
}
