//
//  Band+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 02/11/2022.
//

import Provisioner2

extension Band: CustomStringConvertible {
    public var description: String {
        switch self {
        case .band24Gh:
            return "2.4 GHz"
        case .band5Gh:
            return "5 GHz"
        }
    }
}
