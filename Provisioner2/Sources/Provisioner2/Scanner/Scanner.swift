//
// Created by Nick Kibysh on 07/10/2022.
//

import Foundation
import CoreBluetoothMock

/// Bluetooth Scanner for scanning for nRF-7 Devices
/// Though this class is designed to scan for BLE devices, you don't need to deal with Bluetooth directly.
/// Scanner provides all the necessary wrappers for CoreBluetooth, so you even don't need to import CoreBluetooth.
open class Scanner {
    private (set) var scanResults: [ScanResult] = []
    
    private var internalScanner: InternalScanner
    
    public init(delegate: ScannerDelegate? = nil) {
        self.internalScanner = InternalScanner(
            delegate: delegate,
            centralManager: CBMCentralManagerFactory.instance()
        )
    }

    /// Starts scanning for devices
    open func startScan() {
        internalScanner.startScan()
    }

    /// Stops scanning for devices
    open func stopScan() {
        internalScanner.stopScan()
    }

    /// Reset scan results
    open func reset() {
        scanResults = []
    }
}
