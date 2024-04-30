//
//  ConnectionState+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 02/11/2022.
//

import Foundation
import NordicWiFiProvisioner_BLE

extension ConnectionState {
    var isInProgress: Bool {
        switch self {
        case .disconnected, .connectionFailed, .connected:
            return false
        case .authentication, .association, .obtainingIp:
            return true
        }
    }
}

extension ConnectionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connectionFailed:
            return "Connection Failed"
        case .authentication:
            return "Authentication"
        case .association:
            return "Association"
        case .obtainingIp:
            return "Obtaining IP"
        case .connected:
            return "Connected"
        }
    }
}
