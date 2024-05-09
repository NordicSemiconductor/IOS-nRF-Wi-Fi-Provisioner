//
//  NFCEncryptionType.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 8/5/24.
//

import Foundation

// MARK: - NFCEncryptionType

enum NFCEncryptionType: UInt8, RawRepresentable, Identifiable, CustomStringConvertible, CaseIterable {
    case none = 0x01
    case wep = 0x02
    case tkip = 0x04
    case aes = 0x08
    case aesTkipMixed = 0x0c
    
    var id: UInt8 {
        rawValue
    }
    
    var bytes: [UInt8] {
        [0x00, rawValue]
    }
    
    var description: String {
        switch self {
        case .none:
            return "No Encryption"
        case .wep:
            return "WEP"
        case .tkip:
            return "TKIP"
        case .aes:
            return "AES"
        case .aesTkipMixed:
            return "AES-TKIP Mixed"
        }
    }
}
