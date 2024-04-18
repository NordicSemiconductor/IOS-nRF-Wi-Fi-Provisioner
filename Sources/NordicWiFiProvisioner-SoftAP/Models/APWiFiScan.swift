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
    public let channel: Int
    public let rssi: Int
    public let band: APWiFiBand
    public let authentication: APWiFiAuth
    
    // MARK: Init
    
    init(scanRecord: ScanRecord) {
        let band = APWiFiBand(from: scanRecord.wifi.band)
        let auth = APWiFiAuth(from: scanRecord.wifi.authMode)
        id = scanRecord.wifi.ssid
            .appending(band.description)
            .appending(auth.description)
        ssid = scanRecord.wifi.ssid
        channel = Int(scanRecord.wifi.channel)
        rssi = Int(scanRecord.rssi)
        self.band = band
        self.authentication = auth
    }
}
