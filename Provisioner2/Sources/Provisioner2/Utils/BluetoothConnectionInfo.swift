//
//  File.swift
//  
//
//  Created by Nick Kibysh on 25/10/2022.
//

import Foundation
import CoreBluetoothMock

struct BluetoothConnectionInfo {
    var peripheral: CBPeripheral

    var versionCharacteristic: CBCharacteristic?
    var dataOutCharacteristic: CBCharacteristic?
    var controlPointCharacteristic: CBCharacteristic?
    
    var isReady: Bool {
        if case .connected = peripheral.state {
            return versionCharacteristic.isSome
            && dataOutCharacteristic.isSome
            && controlPointCharacteristic.isSome
        } else {
            return false
        }
    }
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    func readVersion() {
        versionCharacteristic.map { peripheral.readValue(for: $0) }
    }
}
