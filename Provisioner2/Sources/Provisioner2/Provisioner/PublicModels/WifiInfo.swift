//
//  File.swift
//  
//
//  Created by Nick Kibysh on 26/10/2022.
//

import Foundation

public protocol WifiInfo {
    var ssid: String { get }
    var rssi: Int { get }
    var bssid: String { get }
    var band: Band { get }
    var channel: UInt { get }
    var auth: AuthMode { get }
}

extension Envelope: WifiInfo where P == Proto.WifiInfo {
    var bssid: String {
        ""
    }
    
    var band: Band {
        .any
    }
    
    var channel: UInt {
        0
    }
    
    var auth: AuthMode {
        .open
    }
    
    var ssid: String {
        ""
    }
    
    var rssi: Int {
        -1
    }
    
    
}
