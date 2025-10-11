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

#if canImport(JavaScriptCore)
public enum SignatureSolverError: Error {
    case contextCreationFailed
    case resourceNotFound(name: String, extension: String)
    case evaluationFailed
    case resultConversionFailed
    case encodingFailed
    case jsonDecodingFailed(Error)
    case solverError(requestType: String, message: String)
}

extension SignatureSolverError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .contextCreationFailed:
            return NSLocalizedString("Failed to create JavaScript context", comment: "")

        case .resourceNotFound(let name, let ext):
            return NSLocalizedString("JavaScript resource not found: \(name).\(ext)", comment: "")

        case .evaluationFailed:
            return NSLocalizedString("JavaScript evaluation failed", comment: "")

        case .resultConversionFailed:
            return NSLocalizedString("Failed to convert JavaScript result to string", comment: "")

        case .encodingFailed:
            return NSLocalizedString("Failed to encode output as UTF-8", comment: "")

        case .jsonDecodingFailed(let underlyingError):
            return NSLocalizedString("Failed to decode JSON response: \(underlyingError.localizedDescription)", comment: "")

        case .solverError(let requestType, let message):
            return NSLocalizedString("Signature solver error for \(requestType): \(message)", comment: "")
        }
    }

}
#endif
