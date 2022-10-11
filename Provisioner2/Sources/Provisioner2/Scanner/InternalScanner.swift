//
//  InternalScanner.swift
//  
//
//  Created by Nick Kibysh on 10/10/2022.
//

import Foundation
import CoreBluetoothMock

class InternalScanner {
    var delegate: ScannerDelegate?
    var centralManager: CBCentralManager!

    var state: CBManagerState?
    var isScanning = false
    
    init(delegate: ScannerDelegate?, centralManager: CBCentralManager) {
        self.delegate = delegate
        self.centralManager = centralManager
        self.centralManager.delegate = self 
    }
    
    func startScan() {
        if state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [wifiServiceUUID], options: nil)
            delegate?.scannerStartedScanning()
        }
        isScanning = true
    }
    
    func stopScan() {
        isScanning = false
        centralManager.stopScan()
        delegate?.scannerStoppedScanning()
    }
}

extension InternalScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.scannerDidUpdateState(Scanner.State.init(central.state))
        state = central.state

        if case .poweredOn = central.state, !central.isScanning && isScanning {
            startScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let discoveredDevice = DiscoveredDevice(
                peripheral: peripheral,
                advertisementData: advertisementData,
                rssi: RSSI
        )
        delegate?.scannerDidDiscover(discoveredDevice)
    }
}
