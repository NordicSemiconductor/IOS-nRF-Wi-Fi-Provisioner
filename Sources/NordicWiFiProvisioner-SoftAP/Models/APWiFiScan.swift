//
//  APWiFiScan.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 27/3/24.
//

import Foundation

public struct APWiFiScan: Identifiable, Hashable {
    public let ssid: String
    public var id: String { ssid }
    
    init(scanResult: WifiScanResult) {
        ssid = scanResult.ssid
    }
}
