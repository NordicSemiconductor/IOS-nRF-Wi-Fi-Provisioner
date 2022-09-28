//
//  File.swift
//  
//
//  Created by Nick Kibysh on 27/09/2022.
//

#if DEBUG
import Foundation

extension String {
    func decodeBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func encodeBase64() -> Data? {
        return Data(base64Encoded: self)
    }
}

extension Band {
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

extension AuthMode {
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

extension WifiInfo: Decodable {
    enum CodingKeys: CodingKey {
        case ssid
        case bssid
        case band
        case channel
        case auth
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let ssidStr = try container.decode(String.self, forKey: .ssid)
        let bssidStr = try container.decode(String.self, forKey: .bssid)
        let bandStr = try container.decode(String.self, forKey: .band)
        let authStr = try container.decode(String.self, forKey: .auth)

        channel = try container.decode(UInt32.self, forKey: .channel)
        ssid = ssidStr.encodeBase64()!
        bssid = bssidStr.encodeBase64()!
        band = Band(name: bandStr)
        auth = AuthMode(name: authStr)
    }
}

extension ScanRecord: Decodable {
    enum CodingKeys: CodingKey {
        case wifi
        case rssi
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wifi = try container.decode(WifiInfo.self, forKey: .wifi)
        rssi = try container.decode(Int32.self, forKey: .rssi)
    }
}

extension Result: Decodable {
    enum CodingKeys: CodingKey {
        case scanRecord
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scanRecord = try container.decode(ScanRecord.self, forKey: .scanRecord)
    }
}

#endif
