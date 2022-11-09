//
//  Errors.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation

public enum YouTubeKitError: String, Error {
    case maxRetriesExceeded
    case htmlParseError
    case extractError
    case regexMatchError
    case videoUnavailable
    case videoAgeRestricted
    case liveStreamError
    case videoPrivate
    case recordingUnavailable
    case membersOnly
    case videoRegionBlocked
}

extension YouTubeKitError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .videoUnavailable:
            return NSLocalizedString("Video unavailable", comment: "")
            
        case .videoAgeRestricted:
            return NSLocalizedString("Video age restricted", comment: "")
            
        case .liveStreamError:
            return NSLocalizedString("Can't extract video from livestream", comment: "")
            
        case .videoPrivate:
            return NSLocalizedString("Video is private", comment: "")
            
        case .membersOnly:
            return NSLocalizedString("Video is members only", comment: "")
            
        default: return nil
        }
    }
    
}
