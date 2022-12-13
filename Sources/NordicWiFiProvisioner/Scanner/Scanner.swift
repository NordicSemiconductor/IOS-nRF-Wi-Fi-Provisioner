//
// Created by Nick Kibysh on 07/10/2022.
//

import Foundation
import CoreBluetoothMock

/// An object that uses [CBCentralManager](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) to scan for peripherals and filter nRF devices.
///
/// Scanner provides all the necessary methods for scanning nRF-Devices and retrieving data like version or provisioning status, so you even don't need to import  [CoreBluetooth](https://developer.apple.com/documentation/corebluetooth).
open class Scanner {
    private var internalScanner: InternalScanner
    
    /// The delegate that you want to receive scan results.
    open var delegate: ScannerDelegate? {
        get {
            internalScanner.delegate
        }
        set {
            internalScanner.delegate = newValue
        }
    }
    
    /// Initialize a new instance of the `Scanner`.
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
}
