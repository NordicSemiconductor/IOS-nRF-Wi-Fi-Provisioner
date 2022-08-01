//
//  File.swift
//  
//
//  Created by Nick Kibysh on 20/07/2022.
//

import Foundation

public struct AccessPoint: Identifiable {
    let wifiInfo: WifiInfo

    public var ssid: String
    public var id: UUID
    public var isOpen: Bool
    public var channel: Int
    public var rssi: Int

    init(wifiInfo: WifiInfo, RSSI: Int32) {
        self.wifiInfo = wifiInfo
        ssid = String(data: wifiInfo.ssid, encoding: .utf8) ?? "n/a"
        id = UUID()
        isOpen = wifiInfo.auth.isOpen
        channel = Int(wifiInfo.channel)
        rssi = Int(RSSI)
    }

}
