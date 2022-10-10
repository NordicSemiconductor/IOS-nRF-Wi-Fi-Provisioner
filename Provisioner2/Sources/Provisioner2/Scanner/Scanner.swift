//
// Created by Nick Kibysh on 07/10/2022.
//

import Foundation
import CoreBluetoothMock

/// Bluetooth Scanner for scanning for nRF-7 Devices
/// Though this class is designed to scan for BLE devices, you don't need to deal with Bluetooth directly.
/// Scanner provides all the necessary wrappers for CoreBluetooth, so you even don't need to import CoreBluetooth.
open class Scanner {
    var delegate: ScannerDelegate?
    private var centralManager: CBCentralManager!
    
    init(delegate: ScannerDelegate? = nil, centralManager: CBCentralManager = CBMCentralManagerFactory.instance()) {
        self.delegate = delegate
        self.centralManager = centralManager
        self.centralManager.delegate = self
    }
}

extension Scanner: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CoreBluetoothMock.CBMCentralManager) {
        
    }
    
    
}

/*
extension Scanner: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBMPeripheral, error: Error?) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBMPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }

}
*/
