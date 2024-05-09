//
//  NFCAuthenticationType.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 8/5/24.
//

import Foundation

// MARK: - NFCAuthenticationType

enum NFCAuthenticationType: UInt8, RawRepresentable, Identifiable, CustomStringConvertible, CaseIterable {
    case open = 0x01
    case wpaPersonal = 0x02
    case shared = 0x04
    case wpaEnterprise = 0x08
    case wpa2Enterprise = 0x10
    case wpa2Personal = 0x20
    
    var id: UInt8 {
        rawValue
    }
    
    var bytes: [UInt8] {
        [0x00, rawValue]
    }
    
    var description: String {
        switch self {
        case .open:
            return "Open"
        case .wpaPersonal:
            return "WPA Personal"
        case .shared:
            return "Shared"
        case .wpaEnterprise:
            return "WPA Enterprise"
        case .wpa2Enterprise:
            return "WPA2 Enterprise"
        case .wpa2Personal:
            return "WPA2 Personal"
        }
    }
}
