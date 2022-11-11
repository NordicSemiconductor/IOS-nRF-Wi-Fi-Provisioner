//
//  MACAddress+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 02/11/2022.
//

import Foundation
import Provisioner2

extension MACAddress {
    init(i: Int) {
        var _i = i
        self.init(data: Data(bytes: &_i, count: MemoryLayout.size(ofValue: i)))!
    }
}
