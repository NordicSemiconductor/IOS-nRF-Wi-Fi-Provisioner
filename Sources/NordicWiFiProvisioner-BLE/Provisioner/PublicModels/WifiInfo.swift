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

import Foundation

// MARK: - WifiInfo

public struct WifiInfo {
    
    // MARK: Public Properties
    
    public let ssid: String
    public let bssid: MACAddress
    public let band: Band?
    public let channel: UInt
    public let auth: AuthMode?
    
    // MARK: Init
    
    public init(ssid: String, bssid: MACAddress, band: Band? = nil, channel: UInt, auth: AuthMode? = nil) {
        self.ssid = ssid
        self.bssid = bssid
        self.band = band
        self.channel = channel
        self.auth = auth
    }
}

// MARK: - ProtoConvertible

extension WifiInfo: ProtoConvertible {
    
    init(proto: Proto.WifiInfo) {
        self.ssid = String(data: proto.ssid, encoding: .utf8)!
        let data = proto.bssid
        self.bssid = MACAddress(data: data.prefix(6))!
        self.band = proto.hasBand ? Band(proto: proto.band) : nil
        self.channel = UInt(proto.channel)
        self.auth = proto.hasAuth ? AuthMode(proto: proto.auth) : nil
    }
    
    var proto: Proto.WifiInfo {
        var proto = Proto.WifiInfo()
        
        self.ssid.data(using: .utf8).map { proto.ssid = $0 }
        proto.bssid = self.bssid.data
        self.band.map { proto.band = $0.proto }
        proto.channel = UInt32(self.channel)
        self.auth.map { proto.auth = $0.proto }
        
        return proto
    }
}
