# YouTubeKit

This package allows to extract the direct video url or audio url for any YouTube video. This therefore allows to play YouTube videos in native UI components. 

It includes an optional [remote fallback](#remote-fallback) to ensure continued functionality even when YouTube updates their API, bridging the gap until you can update your app.

**Disclaimer:** YouTubeKit is currently still a work in progress, so it might not work in all regions.

## Compatibility
It requires iOS 13, watchOS 6, tvOS 13 or macOS 10.15, since it's relying on the Swift 5.5 Concurrency module. visionOS is also supported.


## Usage

1. Create a `YouTube` object with the `videoURL` or `videoID` of your video:
```swift
let video = YouTube(url: videoURL)
```
or
```swift
let video = YouTube(videoID: videoID)
```


2. Extract all streams:
```swift
let streams = try await video.streams
```
This will return an array of `Stream` objects.


3. Filter for the stream you want by using a normal filter or with provided helper functions like:
```swift
let streamsAt1080 = streams.streams(withExactResolution: 1080)
let streamsBelow1080 = streams.filter(byResolution: $0 < 1080)  // all streams with resolution lower than 1080p
let lowestResolution = streams.lowestResolutionStream()
let highestResolution = streams.highestResolutionStream()
let lowestAudioBitrate = streams.lowestAudioBitrateStream()
let highestAudioBitrate = streams.highestAudioBitrateStream()
let audioOnlyStreams = streams.filterAudioOnly()  // all streams without video track
let videoOnlyStreams = streams.filterVideoOnly()  // all streams without audio track
let combinedStreams = streams.filterVideoAndAudio()  // all streams with both video and audio track
```

4. Retrieve metadata:
```swift
let metadata = try await video.metadata
```
This will return a `YouTubeMetadata` object.



### Example 1
To play a YouTube video in AVPlayer:
```swift
let stream = try await YouTube(videoID: "QdBZY2fkU-0").streams
                          .filterVideoAndAudio()
                          .filter { $0.isNativelyPlayable }
                          .highestResolutionStream()

let player = AVPlayer(url: stream!.url)
// -> Now present the player however you like
```
The `isNativelyPlayable` parameter is used to filter only streams that are natively decodable on the current operating system and device.


### Example 2
To get the best m4a audio-only url for a given YouTube ID:
```swift
let stream = try await YouTube(videoID: "9bZkp7q19f0").streams
                          .filterAudioOnly()
                          .filter { $0.fileExtension == .m4a }
                          .highestAudioBitrateStream()

let streamURL = stream.url
```


### Example 3
To get the video url of type mp4 with the highest available resolution for a given YouTube url:
```swift
let stream = try await YouTube(url: youtubeURL).streams
                          .filter { $0.includesVideoAndAudioTrack && $0.fileExtension == .mp4 }
                          .highestResolutionStream()

let streamURL = stream.url
```
The `includesVideoAndAudioTrack` parameter is used to filter only streams that contain both video and audio.


### Example 4
To get the HLS url for a given YouTube ID of a livestream:
```swift
let hlsManifestUrl = try await YouTube(videoID: "21X5lGlDOfg").livestreams
                          .filter { $0.streamType == .hls }
                          .first
```


## Remote Fallback
With local YouTube extractors, there is the problem that YouTube might suddenly change their unofficial API, which can break your existing shipped app. It can take days or weeks for a user to update your app, rendering some features unusable for them in the meantime. To prevent this, YouTubeKit includes a feature that allows you to enable a remote fallback. As soon as local extraction fails, it switches to using a remote server running `youtube-dl`, that is updated frequently.
Simply specify the `methods` YouTubeKit should use in priority order. The rest of the API remains exactly the same — everything is handled by the library.
```swift
let streams = try await YouTube(videoID: "2lAe1cqCOXo", methods: [.local, .remote]).streams
```
You can also set `methods: [.remote]` if you only want remote extraction.

#### How It Works
Since streams are often bound to the device's location or IP address, we can't simply use `youtube-dl` on a remote server and send back the stream urls. Instead, the server makes all HTTP requests through the requesting device. When starting remote extraction, the device opens a WebSocket connection to the remote server. The server then sends multiple HTTP request packets to the device. The device executes these on behalf of the server and returns the full response. The server then processes and extracts the stream urls and sends them back to the device. This ensures the retrieved stream urls are playable on your device.

The default remote server is hosted by me on Cloudflare Workers. The server implementation is open source and available at [YouTubeKit-Server](https://github.com/alexeichhorn/YouTubeKit-Server/tree/cloudflare-worker), allowing you to host your own instance if desired.


