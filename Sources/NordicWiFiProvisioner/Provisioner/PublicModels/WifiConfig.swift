//
//  File.swift
//  
//
//  Created by Nick Kibysh on 18/11/2022.
//

import Foundation

public struct WifiConfig {
    public var wifi: WifiInfo?
    public var passphrase: String?
    public var volatileMemory: Bool?
    
    public init(wifi: WifiInfo? = nil, passphrase: String? = nil, volatileMemory: Bool? = nil) {
        self.wifi = wifi
        self.passphrase = passphrase
        self.volatileMemory = volatileMemory
    }
}

extension WifiConfig: ProtoConvertible {
    init(proto: Proto.WifiConfig) {
        self.wifi = proto.hasWifi ? WifiInfo(proto: proto.wifi) : nil
        self.passphrase = proto.hasPassphrase ? String(data: proto.passphrase, encoding: .utf8) : nil
        self.volatileMemory = proto.hasVolatileMemory ? proto.volatileMemory : nil
    }
    
    var proto: Proto.WifiConfig {
        var proto = Proto.WifiConfig()
        
        (self.wifi?.proto).map { proto.wifi = $0 }
        (self.passphrase?.data(using: .utf8)).map { proto.passphrase = $0 }
        (self.volatileMemory).map { proto.volatileMemory = $0 }
        
        return proto
    }
}
