//
//  Logging.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 04.09.21.
//

import Foundation
import os.log

@available(iOS 10.0, *)
extension OSLog {
    
    convenience init(category: String) {
        self.init(subsystem: "YouTubeKit", category: category)
    }
    
    convenience init(_ aClass: AnyClass) {
        self.init(subsystem: Bundle(for: aClass).bundleIdentifier!, category: String(describing: aClass))
    }
    
}
