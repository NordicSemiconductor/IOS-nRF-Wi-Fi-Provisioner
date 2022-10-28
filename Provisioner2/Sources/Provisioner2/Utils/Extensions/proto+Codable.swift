//
//  File.swift
//  
//
//  Created by Nick Kibysh on 27/09/2022.
//

#if DEBUG
import Foundation

extension Proto.Band {
    init(name: String) {
        switch name {
        case "BAND_2_4_GH":
            self = .band24Gh
        case "BAND_5_GH":
            self = .band5Gh
        default:
            self = .any
        }
    }
}

extension Proto.AuthMode {
    init(name: String) {
        switch name {
        case "OPEN":
            self = .open
        case "WEP":
            self = .wep
        case "WPA_PSK":
            self = .wpaPsk
        case "WPA2_PSK":
            self = .wpa2Psk
        case "WPA_WPA2_PSK":
            self = .wpaWpa2Psk
        default:
            self = .open
        }
    }
}

extension Proto.WifiInfo: Decodable {
    enum CodingKeys: CodingKey {
        case ssid
        case bssid
        case band
        case channel
        case auth
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let ssidStr = try container.decode(String.self, forKey: .ssid)
        let bssidStr = try container.decode(String.self, forKey: .bssid)
        let bandStr = try container.decode(String.self, forKey: .band)
        let authStr = try container.decode(String.self, forKey: .auth)
        
        channel = try container.decode(UInt32.self, forKey: .channel)
        ssid = ssidStr.encodeBase64()!
        bssid = bssidStr.encodeBase64()!
        band = Proto.Band(name: bandStr)
        auth = Proto.AuthMode(name: authStr)
    }
}

extension Proto.ScanRecord: Decodable {
    enum CodingKeys: CodingKey {
        case wifi
        case rssi
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wifi = try container.decode(Proto.WifiInfo.self, forKey: .wifi)
        rssi = try container.decode(Int32.self, forKey: .rssi)
    }
}

extension Proto.Result: Decodable {
    enum CodingKeys: CodingKey {
        case scanRecord
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scanRecord = try container.decode(Proto.ScanRecord.self, forKey: .scanRecord)
    }
}

#endif
