/*
* Copyright (c) 2024, Nordic Semiconductor
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
