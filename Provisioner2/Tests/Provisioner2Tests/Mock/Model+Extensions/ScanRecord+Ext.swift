//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/11/2022.
//

import Foundation
@testable import Provisioner2

extension Proto.ScanRecord {
    init(wifiInfo: Proto.WifiInfo, rssi: Int32?) {
        self.init()
        self.wifi = wifiInfo
        if let rssi {
            self.rssi = rssi
        }
    }
    
    static let sr1 = Proto.ScanRecord(wifiInfo: WifiInfo.wifi1.proto, rssi: -40)
    static let sr2 = Proto.ScanRecord(wifiInfo: WifiInfo.wifi2.proto, rssi: -60)
    static let sr3 = Proto.ScanRecord(wifiInfo: WifiInfo.wifi3.proto, rssi: -80)
    static let sr4 = Proto.ScanRecord(wifiInfo: WifiInfo.wifi4.proto, rssi: -100)
    
    static let badSR1 = Proto.ScanRecord(wifiInfo: WifiInfo.wifi1.proto, rssi: -100000)
    static let badSR2 = Proto.ScanRecord(wifiInfo: WifiInfo.wifi2.proto, rssi: nil)
}
