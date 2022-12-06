//
//  WiFiInfo+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 16/11/2022.
//

import Foundation
import NordicWiFiProvisioner

extension WifiInfo: Hashable {
    public static func == (lhs: WifiInfo, rhs: WifiInfo) -> Bool {
        lhs.bssid == rhs.bssid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(bssid)
    }
    
    var isOpen: Bool {
        if auth == .open {
            return true
        } else {
            return false
        }
    }
}
