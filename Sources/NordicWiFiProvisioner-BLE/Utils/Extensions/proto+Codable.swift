/*
* Copyright (c) 2022, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

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
