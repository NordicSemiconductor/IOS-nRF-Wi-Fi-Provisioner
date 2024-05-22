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

/// An object that uses [CBCentralManager](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) 
/// to scan for peripherals and filter nRF devices.
///
/// Scanner provides all the necessary methods for scanning nRF-Devices 
/// and retrieving data like version or provisioning status, so you even don't need to import
/// [CoreBluetooth](https://developer.apple.com/documentation/corebluetooth).
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
            centralManager: CBMCentralManagerFactory.instance(forceMock: MockManager.forceMock)
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
