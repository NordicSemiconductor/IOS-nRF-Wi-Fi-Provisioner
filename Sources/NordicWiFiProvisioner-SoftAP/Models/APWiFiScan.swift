//
//  APWiFiScan.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 27/3/24.
//

import Foundation

// MARK: - APWiFiScan

public struct APWiFiScan: Identifiable, Hashable {
    
    // MARK: Public Properties
    
    public let ssid: String
    public let bssid: String
    public let channel: Int
    public let rssi: Int
    public var id: String { ssid }
    
    // MARK: Init
    
    init(scanResult: WifiScanResult) {
        ssid = scanResult.ssid
        bssid = scanResult.bssid
        channel = Int(scanResult.channel)
        rssi = Int(scanResult.rssi)
    }
}
