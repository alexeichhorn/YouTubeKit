# YouTubeKit

This package allows to extract the direct video url or audio url for any YouTube video. This therefore allows to play YouTube videos in native UI components.

**Disclaimer:** YouTubeKit is currently still a work in progress, so it might not work in all regions.

The structurce of the code is strongly aligned with the [pytube project](https://github.com/pytube/pytube) (written in Python). This should make future breaking changes (by the YouTube API) easier to fix.

## Compatibility
It requires iOS 13, watchOS 6, tvOS 13 or macOS 10.15, since it's relying on the Swift 5.5 Concurrency module.


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
let lowestResolution = streams.lowestResolutionStream()
let highestResolution = streams.highestResolutionStream()
let lowestAudioBitrate = streams.lowestAudioBitrateStream()
let highestAudioBitrate = streams.highestAudioBitrateStream()
let audioOnlyStreams = streams.filterAudioOnly()  // all streams without video track
let videoOnlyStreams = streams.filterVideoOnly()  // all streams without audio track
```


### Example 1
To get the video url of type mp4 with the highest available resolution for a given YouTube url:
```swift
let stream = try await YouTube(url: youtubeURL).streams
                          .filter { $0.isProgressive && $0.subtype == "mp4" }
                          .highestResolutionStream()

let streamURL = stream.url                      
```
The `isProgressive` parameter is used to filter only streams that contain both video and audio.


### Example 2
To get the best mp4 audio-only url for a given YouTube ID:
```swift
let stream = try await YouTube(videoID: "9bZkp7q19f0").streams
                          .filterAudioOnly()
                          .filter { $0.subtype == "mp4" }
                          .highestAudioBitrateStream()

let streamURL = stream.url
```

### Example 3
To get the HLS url for a given YouTube ID of a livestream:
```swift
let hlsManifestUrl = try await YouTube(videoID: "21X5lGlDOfg").livestreams
                          .filter { $0.streamType == .hls }
                          .first
```
