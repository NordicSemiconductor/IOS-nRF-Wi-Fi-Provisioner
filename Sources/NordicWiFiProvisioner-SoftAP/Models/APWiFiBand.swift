//
//  APWiFiBand.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 27/3/24.
//

import Foundation

// MARK: - APWiFiBand

public enum APWiFiBand: Hashable, Equatable, CustomStringConvertible {
    case _2_4Ghz
    case _5Ghz
    case _6Ghz
    case unknown
    
    // MARK: Init
    
    init(from scanResultBand: Band) {
        switch scanResultBand {
        case .unspecified, .UNRECOGNIZED:
            self = .unknown
        case .band24Ghz:
            self = ._2_4Ghz
        case .band5Ghz:
            self = ._5Ghz
        case .band6Ghz:
            self = ._6Ghz
        }
    }
    
    // MARK: Properties
    
    public var description: String {
        switch self {
        case ._2_4Ghz:
            return "2.4 Ghz"
        case ._5Ghz:
            return "5 Ghz"
        case ._6Ghz:
            return "6 Ghz"
        case .unknown:
            return "Unknown"
        }
    }
}
