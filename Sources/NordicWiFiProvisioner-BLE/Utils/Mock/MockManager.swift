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
import CoreBluetoothMock

/// Mock manager emulates nRF-7 devices and the whole process of provisioning.
open class MockManager {
    static private(set) var forceMock = false
    
    /// Emulates devices. 
    ///
    /// - Parameter devices: Devices to emulate. If `nil` then default devices will be emulated: not provisioned, provisioned but not connected, provisioned and connected.
    /// - Parameter forceMock: If `true` then mock will be used even if real device is connected.
    open class func emulateDevices(devices: [MockDevice]? = nil, forceMock: Bool = false) {
        MockManager.forceMock = forceMock
        
        CBMCentralManagerMock.simulateInitialState(.poweredOff)
        if let devices = devices {
            CBMCentralManagerMock.simulatePeripherals(devices.map(\.spec))
        } else {
            CBMCentralManagerMock.simulatePeripherals(
                [
                    MockDevice.notProvisioned,
                    MockDevice.provisionedNotConnected,
                    MockDevice.provisionedConnected
                ].map(\.spec)
            )
        }
        CBMCentralManagerMock.simulatePowerOn()
    }
}

