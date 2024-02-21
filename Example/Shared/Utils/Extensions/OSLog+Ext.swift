//
//  OSLog+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 21/02/2024.
//

import Foundation
import OSLog

extension OSLog {
    static let networking = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Networking")
}
