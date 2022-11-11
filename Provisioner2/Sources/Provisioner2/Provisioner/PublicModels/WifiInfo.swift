//
//  File.swift
//  
//
//  Created by Nick Kibysh on 26/10/2022.
//

import Foundation

public struct WifiInfo {
    public var ssid: String?
    public var bssid: MACAddress?
    public var band: Band?
    public var channel: UInt?
    public var auth: AuthMode?
    
    public init(ssid: String? = nil, bssid: MACAddress? = nil, band: Band? = nil, channel: UInt? = nil, auth: AuthMode? = nil) {
        self.ssid = ssid
        self.bssid = bssid
        self.band = band
        self.channel = channel
        self.auth = auth
    }
}

extension WifiInfo: ProtoConvertible {
    init(proto: Proto.WifiInfo) {
        self.ssid = proto.hasSsid ? String(data: proto.ssid, encoding: .utf8) : nil
        self.bssid = proto.hasBssid ? MACAddress(data: proto.bssid) : nil
        self.band = proto.hasBand ? Band(proto: proto.band) : nil
        self.channel = proto.hasChannel ? UInt(proto.channel) : nil
        self.auth = proto.hasAuth ? AuthMode(proto: proto.auth) : nil
    }
    
    var proto: Proto.WifiInfo {
        var proto = Proto.WifiInfo()
        
        self.ssid?.data(using: .utf8).map { proto.ssid = $0 }
        self.bssid.map { proto.bssid = $0.data }
        self.band.map { proto.band = $0.proto }
        self.channel.map { proto.channel = UInt32($0) }
        self.auth.map { proto.auth = $0.proto }
        
        return proto
    }
}
