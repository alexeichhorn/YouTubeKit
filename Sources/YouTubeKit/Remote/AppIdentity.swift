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
#if os(macOS) || targetEnvironment(macCatalyst)
        return getCurrentFromEntitlement() ?? getCurrentFromBundle() ?? getCurrentFromKeychain()
#else
        return getCurrentFromKeychain() ?? getCurrentFromBundle()
#endif
    }

#if os(macOS) || targetEnvironment(macCatalyst)
    static func getCurrentFromEntitlement() -> Self? {
        guard let appID = getEntitlementValue(forKey: "application-identifier")
                       ?? getEntitlementValue(forKey: "com.apple.application-identifier"),
              let dot = appID.firstIndex(of: ".")
        else { return nil }
        
        let extractedTeamID = String(appID[..<dot])
        let extractedBundleID = String(appID[appID.index(after: dot)...])
        
        return AppIdentity(teamID: extractedTeamID, bundleID: extractedBundleID)
    }
    
    static private func getEntitlementValue(forKey key: String) -> String? {
        guard let task = SecTaskCreateFromSelf(nil),
              let value = SecTaskCopyValueForEntitlement(task, key as CFString, nil) as? String
        else { return nil }
        
        return value
    }
#endif

    static func getCurrentFromBundle() -> Self? {
        let bundleID = Bundle.main.bundleIdentifier ?? (Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String)
        return bundleID.map { AppIdentity(teamID: "", bundleID: $0) }
    }

    /// iOS-friendly way to derive Team ID using the app's keychain access group.
    /// Requires the app to be properly signed; works in production where
    /// `embedded.mobileprovision` isn't available.
    static func getCurrentFromKeychain() -> Self? {
        let service = "AppIdentity.TeamID.Probe"
        let account = "probe"

        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnAttributes: true
        ]

        var item: CFTypeRef?
        var status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            query[kSecValueData] = Data("x".utf8)
            _ = SecItemAdd(query as CFDictionary, nil)
            status = SecItemCopyMatching(query as CFDictionary, &item)
        }

        guard status == errSecSuccess,
              let attrs = item as? [CFString: Any],
              let accessGroup = attrs[kSecAttrAccessGroup] as? String,
              let bundleID = Bundle.main.bundleIdentifier
        else { return nil }

        // Access group looks like "<TEAMID>.<something>"
        let teamID = accessGroup.split(separator: ".").first.map(String.init) ?? ""
        return AppIdentity(teamID: teamID, bundleID: bundleID)
    }

}
