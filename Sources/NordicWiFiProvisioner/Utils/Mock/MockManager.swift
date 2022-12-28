//
//  File.swift
//  
//
//  Created by Nick Kibysh on 13/12/2022.
//

import CoreBluetoothMock

/// Mock manager emulates nRF-7 devices and the whole process of provisioning.
open class MockManager {
    static var forceMock = false
    
    /// Emulates devices. 
    ///
    /// - Parameter devices: Devices to emulate. If `nil` then default devices will be emulated: not provisioned, provisioned but not connected, provisioned and connected.
    open class func emulateDevices(devices: [MockDevice]? = nil, forceMock: Bool = false) {
        self.forceMock = forceMock
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
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

