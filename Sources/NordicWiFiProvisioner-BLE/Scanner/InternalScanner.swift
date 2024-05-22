/*
* Copyright (c) 2022, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import CoreBluetoothMock
import os

class InternalScanner {
    weak var delegate: ScannerDelegate?
    var centralManager: CBCentralManager!

    var state: CBManagerState?
    var isScanning = false

    let logger = Logger(
        subsystem: Bundle(for: InternalScanner.self).bundleIdentifier ?? "",
        category: "scanner.internal-scanner"
    )
    
    init(delegate: ScannerDelegate?, centralManager: CBCentralManager) {
        self.delegate = delegate
        self.centralManager = centralManager
        self.centralManager.delegate = self 
    }
    
    func startScan() {
        if state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [ServiceID.wifi.cbm], options: nil)
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

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, 
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let discoveredDevice = ScanResult(
                peripheral: peripheral,
                advertisementData: advertisementData,
                rssi: RSSI
        )
        delegate?.scannerDidDiscover(discoveredDevice)
        logger.debug("Discovered device: \(discoveredDevice)")
    }
}
