//
//  File.swift
//  
//
//  Created by Nick Kibysh on 20/07/2022.
//

import Foundation

extension Band {
    // convert to AccessPoint.Frequency
    var frequency: AccessPoint.Frequency {
        switch self {
        case .band24Gh:
            return ._2_4GHz
        case .band5Gh:
            return ._5GHz
        case .any:
            return .any
        }
    }
}

public struct AccessPoint: Identifiable, Hashable, Equatable {
    public enum Frequency {
        case any
        case _2_4GHz
        case _5GHz

        public var stringValue: String {
            switch self {
            case .any:
                return ""
            case ._2_4GHz:
                return "2.4 GHz"
            case ._5GHz:
                return "5 GHz"
            }
        }
    }

    let wifiInfo: WifiInfo

    public var ssid: String
    public var bssid: String
    public var id: String
    public var isOpen: Bool
    public var channel: Int
    public var rssi: Int
    public var frequency: Frequency
    
    #if DEBUG
    // Init with all fields for testing
    public init(ssid: String, bssid: String, id: String, isOpen: Bool, channel: Int, rssi: Int, frequency: Frequency) {
        self.ssid = ssid
        self.bssid = bssid
        self.id = id
        self.isOpen = isOpen
        self.channel = channel
        self.rssi = rssi
        self.frequency = frequency
        self.wifiInfo = WifiInfo()
    }
    #endif

    init(wifiInfo: WifiInfo, RSSI: Int32) {
        self.wifiInfo = wifiInfo
        ssid = String(data: wifiInfo.ssid, encoding: .utf8) ?? "n/a"
        bssid = wifiInfo.bssid
            .map { String(format: "%02hhX", $0) }
            .joined()
        isOpen = wifiInfo.auth.isOpen
        channel = Int(wifiInfo.channel)
        frequency = wifiInfo.band.frequency
        rssi = Int(RSSI)
        let codedId: String = (ssid + bssid + "\(channel)" + frequency.stringValue + "\(rssi)" + (isOpen ? "open" : "closed"))
        self.id = codedId.decodeBase64() ?? codedId
    }

}
