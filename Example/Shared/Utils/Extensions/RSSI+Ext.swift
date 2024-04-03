//
//  RSSI+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 29/07/2022.
//  Created by Dinesh Harjani on 3/4/24.
//

import Foundation
import iOS_Common_Libraries

// MARK: - RSSI Extension

extension RSSI {

    // MARK: WiFi
    
    init(wifiLevel: Int) {
        switch wifiLevel {
        case 5...: 
            self = .outOfRange
        case (-60)...: 
            self = .good
        case (-90)...: 
            self = .ok
        case (-100)...: 
            self = .bad
        default:
            self = .practicalWorst
        }
    }
    
    // MARK: BLE
    
    init(bleLevel: Int) {
        switch bleLevel {
        case 5...: 
            self = .outOfRange
        case (-60)...: 
            self = .good
        case (-90)...: 
            self = .ok
        case (-100)...: 
            self = .bad
        default: 
            self = .practicalWorst
        }
    }

    var isNearby: Bool {
        switch self {
        case .practicalBest, .good, .ok:
            return true
        case .bad, .outOfRange, .practicalWorst:
            return false
        }
    }
}
