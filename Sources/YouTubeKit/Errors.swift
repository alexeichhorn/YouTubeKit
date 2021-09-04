//
//  Errors.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation

enum YouTubeKitError: Error {
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
