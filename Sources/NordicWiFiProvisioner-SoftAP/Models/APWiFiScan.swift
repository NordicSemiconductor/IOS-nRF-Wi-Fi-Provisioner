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
    public let bssid: [UInt8]
    public let channel: Int
    public let rssi: Int
    public let band: APWiFiBand
    public let authentication: APWiFiAuth
    private let wifiInfo: WifiInfo
    
    // MARK: Init
    
    init(scanRecord: ScanRecord) throws {
        let band = APWiFiBand(from: scanRecord.wifi.band)
        let auth = APWiFiAuth(from: scanRecord.wifi.auth)
        
        guard let ssid = String(data: scanRecord.wifi.ssid, encoding: .utf8) else {
            throw ProvisionManager.ProvisionError.badResponse
        }
        id = ssid
            .appending(scanRecord.wifi.channel.description)
            .appending(band.description)
            .appending(auth.description)
        self.ssid = ssid
        self.bssid = scanRecord.wifi.bssid.map { $0 }
        channel = Int(scanRecord.wifi.channel)
        rssi = Int(scanRecord.rssi)
        self.band = band
        self.authentication = auth
        self.wifiInfo = scanRecord.wifi
    }
    
    // MARK: API
    
    public func bssidString() -> String {
        return bssid
            .map({ "\(Int($0))" })
            .joined(separator: ":")
    }
    
    // MARK: Internal API
    
    internal func info() -> WifiInfo {
        return wifiInfo
    }
}
