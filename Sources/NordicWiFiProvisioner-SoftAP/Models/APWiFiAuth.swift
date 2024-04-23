//
//  APWiFiAuth.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 27/3/24.
//

import Foundation

// MARK: - APWiFiAuth

public enum APWiFiAuth: Hashable, Equatable, CustomStringConvertible {
    
    case open
    case wep
    case wpaPsk
    case wpa2Psk
    case wpaWpa2Psk
    case wpa2Enterprise
    case wpa3Psk
    
    // MARK: Init
    
    init(from mode: AuthMode) {
        switch mode {
        case .open:
            self = .open
        case .wep:
            self = .wep
        case .wpaPsk:
            self = .wpaPsk
        case .wpa2Psk:
            self = .wpa2Psk
        case .wpaWpa2Psk:
            self = .wpaWpa2Psk
        case .wpa2Enterprise:
            self = .wpa2Enterprise
        case .wpa3Psk:
            self = .wpa3Psk
        }
    }
    
    // MARK: Properties
    
    public var description: String {
        switch self {
        case .open:
            return "Open"
        case .wep:
            return "WEP"
        case .wpaPsk:
            return "WPAPSK"
        case .wpa2Psk:
            return "WPA2PSK"
        case .wpaWpa2Psk:
            return "WPA_WPA2PSK"
        case .wpa2Enterprise:
            return "WPA2 Enterprise"
        case .wpa3Psk:
            return "WPA3 PSK"
        }
    }
}
