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
    
    public var id: String { bssid }
    
    public let ssid: String
    public let bssid: String
    public let channel: Int
    public let rssi: Int
    public let band: APWiFiBand
    public let authentication: APWiFiAuth
    
    // MARK: Init
    
    init(scanResult: WifiScanResult) {
        ssid = scanResult.ssid
        bssid = scanResult.bssid
        channel = Int(scanResult.channel)
        rssi = Int(scanResult.rssi)
        band = APWiFiBand(from: scanResult.band)
        authentication = APWiFiAuth(from: scanResult.authMode)
    }
}
