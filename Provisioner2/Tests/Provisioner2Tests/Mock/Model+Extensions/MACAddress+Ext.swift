//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/11/2022.
//

import Foundation
import Provisioner2

extension MACAddress {
    static let mac1 = MACAddress(data: 0x01_02_03_04_05_06.toData().suffix(6))
    static let mac2 = MACAddress(data: 0xaa_bb_cc_dd_ee_ff.toData().suffix(6))
    static let mac3 = MACAddress(data: 0x1a_2b_3c_4d_5e_6f.toData().suffix(6))
    static let mac4 = MACAddress(data: 0xa1_b2_c3_d4_e5_f6.toData().suffix(6))
}
