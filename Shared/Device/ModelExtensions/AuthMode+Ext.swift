//
//  AuthMode+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 02/11/2022.
//

import Foundation
import NordicWiFiProvisioner

extension AuthMode {
    var isOpen: Bool {
        if case .open = self {
            return true
        } else {
            return false 
        }
    }
}
