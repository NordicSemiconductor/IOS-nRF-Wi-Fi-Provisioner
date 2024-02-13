//
//  File.swift
//  
//
//  Created by Nick Kibysh on 26/10/2022.
//

import Foundation

/// Wi-Fi details.
public struct WifiInfo {
    public var ssid: String
    public var bssid: MACAddress
    public var band: Band?
    public var channel: UInt
    public var auth: AuthMode?
    
    public init(ssid: String, bssid: MACAddress, band: Band? = nil, channel: UInt, auth: AuthMode? = nil) {
        self.ssid = ssid
        self.bssid = bssid
        self.band = band
        self.channel = channel
        self.auth = auth
    }
}

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
