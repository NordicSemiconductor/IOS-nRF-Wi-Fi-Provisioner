//
//  APWiFiBand.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 27/3/24.
//

import Foundation

// MARK: - APWiFiBand

public enum APWiFiBand: Int, RawRepresentable, Hashable, Equatable, CustomStringConvertible {
    case unknown = 0
    case _2_4Ghz = 1
    case _5Ghz = 2
    
    // MARK: Init
    
    init(from scanResultBand: Band) {
        switch scanResultBand {
        case .any:
            self = .unknown
        case .band24Ghz:
            self = ._2_4Ghz
        case .band5Ghz:
            self = ._5Ghz
        }
    }
    
    // MARK: Properties
    
    public var description: String {
        switch self {
        case ._2_4Ghz:
            return "2.4 Ghz"
        case ._5Ghz:
            return "5 Ghz"
        case .unknown:
            return "Unknown"
        }
    }
}
