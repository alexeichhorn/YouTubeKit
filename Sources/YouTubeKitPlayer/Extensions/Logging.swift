//
//  Logging.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation
import os.log

@available(iOS 10.0, watchOS 3.0, tvOS 10.0, macOS 10.12, *)
extension OSLog {
    
    convenience init(category: String) {
        self.init(subsystem: "YouTubeKit", category: category)
    }
    
    convenience init(_ aClass: AnyClass) {
        self.init(subsystem: Bundle(for: aClass).bundleIdentifier ?? "YouTubeKit", category: String(describing: aClass))
    }
    
}
