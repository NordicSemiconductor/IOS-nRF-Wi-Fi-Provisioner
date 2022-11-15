//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/11/2022.
//

import Foundation
import Provisioner2

extension WifiInfo {
    static let wifi1 = WifiInfo(ssid: "WiFi-1", bssid: MACAddress.mac1, band: .band24Gh, channel: 1, auth: .open)
    static let wifi2 = WifiInfo(ssid: "WiFi-2", bssid: MACAddress.mac2, band: .band5Gh, channel: 1, auth: .wpa2Psk)
    static let wifi3 = WifiInfo(ssid: "WiFi-3", bssid: MACAddress.mac3, band: .band24Gh, channel: 1, auth: .wep)
    static let wifi4 = WifiInfo(ssid: "WiFi-4", bssid: MACAddress.mac4, band: .band5Gh, channel: 1, auth: .wpa3Psk)
}
