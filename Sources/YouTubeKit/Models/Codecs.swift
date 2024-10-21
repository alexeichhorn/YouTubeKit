//
//  Codecs.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 12.11.23.
//

import Foundation

protocol Codec: Sendable {
    associatedtype BaseCodec where BaseCodec: Equatable
    
    var baseCodec: BaseCodec? { get }
    init(rawValue: String)
    
    var isNativelyPlayable: Bool { get }
}

// MARK: - Video Codec

public enum VideoCodec: Codec {
    case mp4v(version: String)
    case av1(version: String)
    case avc1(version: String)
    case vp9(version: String)
    case unknown(codec: String)
    
    public enum BaseCodec {
        case mp4v, av1, avc1, vp9
    }
    
    var baseCodec: BaseCodec? {
        switch self {
        case .av1(_): return .av1
        case .avc1(_): return .avc1
        case .mp4v(_): return .mp4v
        case .vp9(_): return .vp9
        case .unknown(_): return nil
        }
    }
    
    init(rawValue: String) {
        let codecComponents = rawValue.components(separatedBy: ".")
        let baseCodec = codecComponents.first
        let codecVersion = codecComponents[1...].joined(separator: ".")
        
        switch baseCodec {
        case "mp4v":
            self = .mp4v(version: codecVersion)
        case "av1", "av01":
            self = .av1(version: codecVersion)
        case "avc1":
            self = .avc1(version: codecVersion)
        case "vp09", "vp9":
            self = .vp9(version: codecVersion)
        default:
            self = .unknown(codec: rawValue)
        }
    }
    
    public var isNativelyPlayable: Bool {
        switch self {
        case .mp4v(_): return true
        case .av1(_): return false
#if os(watchOS)
        case .avc1(let version):
            if version == "64002A" {
                return false
            }
            return true
#else
        case .avc1(_): return true
#endif
        case .vp9(_): return false
        case .unknown(_): return false
        }
    }
    
}

// MARK: - Audio Codec

public enum AudioCodec: Codec, Equatable {
    case mp4a(version: String)
    case opus
    case ec3
    case ac3
    case unknown(codec: String)
    
    public enum BaseCodec {
        case mp4a, opus, ec3, ac3
    }
    
    var baseCodec: BaseCodec? {
        switch self {
        case .mp4a(_): return .mp4a
        case .opus: return .opus
        case .ec3: return .ec3
        case .ac3: return .ac3
        case .unknown(_): return nil
        }
    }
    
    init(rawValue: String) {
        let codecComponents = rawValue.components(separatedBy: ".")
        let baseCodec = codecComponents.first
        let codecVersion = codecComponents[1...].joined(separator: ".")
        
        switch baseCodec {
        case "mp4a":
            self = .mp4a(version: codecVersion)
        case "opus":
            self = .opus
        case "ec-3":
            self = .ec3
        case "ac-3":
            self = .ac3
        default:
            self = .unknown(codec: rawValue)
        }
    }
    
    public var isNativelyPlayable: Bool {
        switch self {
        case .mp4a(_): return true
        case .opus: return false
#if os(watchOS)
        case .ec3: return false
        case .ac3: return true
#else
        case .ec3, .ac3: return true
#endif
        case .unknown(_): return false
        }
    }
    
}

// -

extension Codec {
    
    public static func == (lhs: Self, rhs: Self.BaseCodec) -> Bool {
        lhs.baseCodec == rhs
    }
    
}

public func ==(lhs: VideoCodec?, rhs: VideoCodec.BaseCodec) -> Bool {
    lhs?.baseCodec == rhs
}

public func ==(lhs: AudioCodec?, rhs: AudioCodec.BaseCodec) -> Bool {
    lhs?.baseCodec == rhs
}

public func !=(lhs: VideoCodec?, rhs: VideoCodec.BaseCodec) -> Bool {
    !(lhs == rhs)
}

public func !=(lhs: AudioCodec?, rhs: AudioCodec.BaseCodec) -> Bool {
    !(lhs == rhs)
}
