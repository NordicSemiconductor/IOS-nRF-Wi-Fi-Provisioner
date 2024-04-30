//
//  WifiScanResult.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 04/09/2022.
//  Created by Dinesh Harjani on 9/4/24.
//

import Foundation
import NordicWiFiProvisioner_BLE

// MARK: - WifiScanResult

struct WifiScanResult: Hashable, Equatable, Identifiable {
    
    // MARK: Properties
    
    let wifi: WifiInfo
    let rssi: Int?
    
    var id: String {
        wifi.bssid.description + "\(wifi.channel)"
    }
    
    // MARK: Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wifi.bssid)
        hasher.combine(wifi.channel)
    }
    
    // MARK: Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wifi.bssid == rhs.wifi.bssid
    }
}
