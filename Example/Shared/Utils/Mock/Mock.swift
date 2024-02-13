//
//  Mock.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 16/11/2022.
//

import Foundation
import NordicWiFiProvisioner_BLE

#if DEBUG
extension Int {
    func toData() -> Data {
        var value = self
        let data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        let arr = [UInt8](data)
        return Data(arr.reversed())
    }
}

extension MACAddress {
    static let mac1 = MACAddress(data: 0x01_02_03_04_05_06.toData().suffix(6))!
    static let mac2 = MACAddress(data: 0xaa_bb_cc_dd_ee_ff.toData().suffix(6))!
    static let mac3 = MACAddress(data: 0x1a_2b_3c_4d_5e_6f.toData().suffix(6))!
    static let mac4 = MACAddress(data: 0xa1_b2_c3_d4_e5_f6.toData().suffix(6))!
}

extension WifiInfo {
    static let wifi1 = WifiInfo(ssid: "WiFi-1", bssid: MACAddress.mac1, band: .band24Gh, channel: 1, auth: .open)
    static let wifi2 = WifiInfo(ssid: "WiFi-2", bssid: MACAddress.mac2, band: .band5Gh, channel: 1, auth: .wpa2Psk)
    static let wifi3 = WifiInfo(ssid: "WiFi-3", bssid: MACAddress.mac3, band: .band24Gh, channel: 1, auth: .wep)
    static let wifi4 = WifiInfo(ssid: "WiFi-4", bssid: MACAddress.mac4, band: .band5Gh, channel: 1, auth: .wpa3Psk)
}
#endif
