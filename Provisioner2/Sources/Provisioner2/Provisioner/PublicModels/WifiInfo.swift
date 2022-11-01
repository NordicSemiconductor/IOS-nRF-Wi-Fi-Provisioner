//
//  File.swift
//  
//
//  Created by Nick Kibysh on 26/10/2022.
//

import Foundation

public protocol WifiInfo {
    var ssid: String? { get }
    var bssid: MACAddress { get }
    var band: Band { get }
    var channel: UInt { get }
    var auth: AuthMode { get }
}

extension Envelope: WifiInfo where P == Proto.WifiInfo {
    var bssid: MACAddress {
        MACAddress(data: model.bssid)
    }
    
    var band: Band {
        Band(proto: model.band)
    }
    
    var channel: UInt {
        UInt(model.channel)
    }
    
    var auth: AuthMode {
        AuthMode(proto: model.auth)
    }
    
    var ssid: String? {
        String(data: model.ssid, encoding: .utf8)
    }
}
