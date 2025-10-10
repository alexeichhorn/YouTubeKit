//
//  AppIdentity.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 02.10.2025.
//

import Foundation
import Security
import CryptoKit

struct AppIdentity {
    let teamID: String
    let bundleID: String
    
    var appID: String {
        teamID + "." + bundleID
    }
    
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    var hashedAppID: String {
        let data = Data(appID.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Retrieval
    
    static func getCurrent() -> Self? {
        return getCurrentFromEntitlement() ?? getCurrentFromBundle()
    }
    
    static func getCurrentFromEntitlement() -> Self? {
        guard let appID = getEntitlementValue(forKey: "application-identifier")
                       ?? getEntitlementValue(forKey: "com.apple.application-identifier"),
              let dot = appID.firstIndex(of: ".")
        else { return nil }
        
        let extractedTeamID = String(appID[..<dot])
        let extractedBundleID = String(appID[appID.index(after: dot)...])

        return AppIdentity(teamID: extractedTeamID, bundleID: extractedBundleID)
    }
    
    static func getCurrentFromBundle() -> Self? {
        let bundleID = Bundle.main.bundleIdentifier ?? (Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String)

        // Try to still obtain teamID from entitlements (may be present even if appID wasn't)
        let teamID = getEntitlementValue(forKey: "com.apple.developer.team-identifier")
                  ?? getEntitlementValue(forKey: "team-identifier") // rare, legacy

        return bundleID.map { AppIdentity(teamID: teamID ?? "", bundleID: $0) }
    }
    
    static private func getEntitlementValue(forKey key: String) -> String? {
        guard let task = SecTaskCreateFromSelf(nil),
              let value = SecTaskCopyValueForEntitlement(task, key as CFString, nil) as? String
        else { return nil }
        
        return value
    }
    
}
