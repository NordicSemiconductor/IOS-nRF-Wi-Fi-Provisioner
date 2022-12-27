//
//  File.swift
//  
//
//  Created by Nick Kibysh on 17/10/2022.
//

import Foundation
import os

/*
 let logger = Logger(
     subsystem: Bundle(for: ScannerViewModel.self).bundleIdentifier ?? "",
     category: "scanner.scanner-view-model"
 )
 */

struct Logger {
    enum Privacy {
        case `public`
        case `private`
    }
    
    let subsystem: String
    let category: String
    
    private func log(_ message: String, type: OSLogType = .default, privacy: Privacy = .public) {
        if case .private = privacy {
            os_log("%{private}s", log: OSLog(subsystem: subsystem, category: category), type: type, message)
        } else {
            os_log("%{public}s", log: OSLog(subsystem: subsystem, category: category), type: type, message)
        }
    }
    
    func debug(_ message: String, privacy: Privacy = .public) {
        log(message, type: .debug, privacy: privacy)
    }

    func info(_ message: String, privacy: Privacy = .public) {
        log(message, type: .info, privacy: privacy)
    }

    func error(_ message: String, privacy: Privacy = .public) {
        log(message, type: .error, privacy: privacy)
    }

    func fault(_ message: String, privacy: Privacy = .public) {
        log(message, type: .fault, privacy: privacy)
    }
    
    func `default`(_ message: String, privacy: Privacy = .public) {
        log(message, type: .default, privacy: privacy)
    }


}
