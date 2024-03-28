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
    
    public let id: String
    
    public let ssid: String
    public let bssid: String
    public let channel: Int
    public let rssi: Int
    public let band: APWiFiBand
    public let authentication: APWiFiAuth
    
    // MARK: Init
    
    init(scanResult: WifiScanResult) {
        let band = APWiFiBand(from: scanResult.band)
        let auth = APWiFiAuth(from: scanResult.authMode)
        id = scanResult.bssid
            .appending(band.description)
            .appending(auth.description)
        ssid = scanResult.ssid
        bssid = scanResult.bssid
        channel = Int(scanResult.channel)
        rssi = Int(scanResult.rssi)
        self.band = band
        self.authentication = auth
    }
}
