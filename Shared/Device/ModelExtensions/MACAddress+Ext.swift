//
//  MACAddress+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 02/11/2022.
//

import Foundation
import Provisioner

extension MACAddress {
    init(i: Int) {
        self.init(data: i.toData().suffix(6))!
    }
}
