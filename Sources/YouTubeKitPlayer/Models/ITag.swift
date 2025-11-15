//
//  File.swift
//  File
//
//  Created by Alexander Eichhorn on 06.09.21.
//

import Foundation

public struct ITag: Sendable {
    
    let itag: Int
    
    /// lower side of resolution (e.g. 1080 for 1080p)
    let videoResolution: Int?
    
    /// in kbps
    let audioBitrate: Int?
    
    init?(_ itag: Int) {
        self.itag = itag
        
        guard let rates = ALL_ITAGS[itag] else {
            return nil
        }
        
        videoResolution = rates.0
        audioBitrate = rates.1
    }
    
    var isHDR: Bool {
        [330, 331, 332, 333, 334, 335, 336, 337].contains(itag)
    }
    
    var is3D: Bool {
        [82, 83, 84, 85, 100, 101, 102].contains(itag)
    }
    
    var isLive: Bool {
        [91, 92, 93, 94, 95, 96, 132, 151].contains(itag)
    }
    
    var isSurroundSound: Bool {
        [380, 328].contains(itag)
    }
    
    var isDash: Bool {
        DASH_AUDIO.keys.contains(itag) || DASH_VIDEO.keys.contains(itag)
    }
    
    var isHLS: Bool {
        HLS_VIDEO.keys.contains(itag)
    }
    
}

fileprivate let PROGRESSIVE_VIDEO: [Int: (Int?, Int?)] = [
    5: (240, 64),
    6: (270, 64),
    13: (144, nil),
    17: (144, 24),
    18: (360, 96),
    22: (720, 192),
    34: (360, 128),
    35: (480, 128),
    36: (240, nil),
    37: (1080, 192),
    38: (3072, 192),
    43: (360, 128),
    44: (480, 128),
    45: (720, 192),
    46: (1080, 192),
    59: (480, 128),
    78: (480, 128),
    82: (360, 128),
    83: (480, 128),
    84: (720, 192),
    85: (1080, 192),
    91: (144, 48),
    92: (240, 48),
    93: (360, 128),
    94: (480, 128),
    95: (720, 256),
    96: (1080, 256),
    100: (360, 128),
    101: (480, 192),
    102: (720, 192),
    132: (240, 48),
    151: (720, 24),
    300: (720, 128),
    301: (1080, 128),
]

fileprivate let HLS_VIDEO: [Int: (Int?, Int?)] = [
    269: (144, nil),
    229: (240, nil),
    230: (360, nil),
    231: (480, nil),
    232: (720, nil),
    270: (1080, nil),
    319: (1440, nil),
    321: (2160, nil),
]

fileprivate let DASH_VIDEO: [Int: (Int?, Int?)] = [
    // DASH Video
    133: (240, nil),  // MP4
    134: (360, nil),  // MP4
    135: (480, nil),  // MP4
    136: (720, nil),  // MP4
    137: (1080, nil),  // MP4
    138: (2160, nil),  // MP4
    160: (144, nil),  // MP4
    167: (360, nil),  // WEBM
    168: (480, nil),  // WEBM
    169: (720, nil),  // WEBM
    170: (1080, nil),  // WEBM
    212: (480, nil),  // MP4
    218: (480, nil),  // WEBM
    219: (480, nil),  // WEBM
    242: (240, nil),  // WEBM
    243: (360, nil),  // WEBM
    244: (480, nil),  // WEBM
    245: (480, nil),  // WEBM
    246: (480, nil),  // WEBM
    247: (720, nil),  // WEBM
    248: (1080, nil),  // WEBM
    264: (1440, nil),  // MP4
    266: (2160, nil),  // MP4
    271: (1440, nil),  // WEBM
    272: (4320, nil),  // WEBM
    278: (144, nil),  // WEBM
    298: (720, nil),  // MP4
    299: (1080, nil),  // MP4
    302: (720, nil),  // WEBM
    303: (1080, nil),  // WEBM
    308: (1440, nil),  // WEBM
    313: (2160, nil),  // WEBM
    315: (2160, nil),  // WEBM
    330: (144, nil),  // WEBM
    331: (240, nil),  // WEBM
    332: (360, nil),  // WEBM
    333: (480, nil),  // WEBM
    334: (720, nil),  // WEBM
    335: (1080, nil),  // WEBM
    336: (1440, nil),  // WEBM
    337: (2160, nil),  // WEBM
    394: (144, nil),  // MP4
    395: (240, nil),  // MP4
    396: (360, nil),  // MP4
    397: (480, nil),  // MP4
    398: (720, nil),  // MP4
    399: (1080, nil),  // MP4
    400: (1440, nil),  // MP4
    401: (2160, nil),  // MP4
    402: (4320, nil),  // MP4
    571: (4320, nil),  // MP4
    694: (144, nil),  // MP4
    695: (240, nil),  // MP4
    696: (360, nil),  // MP4
    697: (480, nil),  // MP4
    698: (720, nil),  // MP4
    699: (1080, nil),  // MP4
    700: (1440, nil),  // MP4
    701: (2160, nil),  // MP4
    702: (4320, nil),  // MP4
]

fileprivate let DASH_AUDIO: [Int: (Int?, Int?)] = [
    // DASH Audio
    139: (nil, 48),  // MP4
    140: (nil, 128),  // MP4
    141: (nil, 256),  // MP4
    171: (nil, 128),  // WEBM
    172: (nil, 256),  // WEBM
    249: (nil, 50),  // WEBM
    250: (nil, 70),  // WEBM
    251: (nil, 160),  // WEBM
    256: (nil, 192),  // MP4
    258: (nil, 384),  // MP4
    325: (nil, nil),  // MP4
    328: (nil, nil),  // MP4 (ec-3 surround)
    380: (nil, nil),  // MP4 (ac-3 surround)
]

fileprivate let ALL_ITAGS = PROGRESSIVE_VIDEO.merging(with: HLS_VIDEO).merging(with: DASH_VIDEO).merging(with: DASH_AUDIO)
