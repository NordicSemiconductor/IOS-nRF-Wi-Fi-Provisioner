//
//  OpCode+Ext.swift
//  
//
//  Created by Nick Kibysh on 27/07/2022.
//

import Foundation

extension OpCode: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .reserved:
            return "reserved"
        case .getStatus:
            return "getStatus"
        case .startScan:
            return "startScan"
        case .stopScan:
            return "stopScan"
        case .setConfig:
            return "setConfig"
        case .forgetConfig:
            return "forgetConfig"
        }
    }
}
