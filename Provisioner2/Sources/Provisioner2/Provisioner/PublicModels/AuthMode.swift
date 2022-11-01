//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

public enum AuthMode: Equatable {
    case open
    case wep
    case wpaPsk
    case wpa2Psk
    case wpaWpa2Psk
    case wpa2Enterprise
    case wpa3Psk
}

extension AuthMode: ProtoConvertible {
    var proto: Proto.AuthMode {
        switch self {
        case .open:
            return .open
        case .wep:
            return .wep
        case .wpaPsk:
            return .wpaPsk
        case .wpa2Psk:
            return .wpa2Psk
        case .wpaWpa2Psk:
            return .wpaWpa2Psk
        case .wpa2Enterprise:
            return .wpa2Enterprise
        case .wpa3Psk:
            return .wpa3Psk
        }
    }
    
    init(proto: Proto.AuthMode) {
        switch proto {
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
}
