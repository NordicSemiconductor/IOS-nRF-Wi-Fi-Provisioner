//
//  File.swift
//  
//
//  Created by Nick Kibysh on 20/07/2022.
//

import Foundation

public struct AccessPoint: Identifiable, Hashable, Equatable {
    let wifiInfo: WifiInfo

    public var ssid: String
    public var id: String
    public var isOpen: Bool
    public var channel: Int
    public var rssi: Int

    init(wifiInfo: WifiInfo, RSSI: Int32) {
        self.wifiInfo = wifiInfo
        ssid = String(data: wifiInfo.ssid, encoding: .utf8) ?? "n/a"
        id = ssid + String(wifiInfo.channel)
        isOpen = wifiInfo.auth.isOpen
        channel = Int(wifiInfo.channel)
        rssi = Int(RSSI)
    }

    public static func == (lhs: AccessPoint, rhs: AccessPoint) -> Bool {
        lhs.ssid == rhs.ssid && lhs.channel == rhs.channel
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ssid)
        hasher.combine(channel)
    }

}
