//
//  File.swift
//  
//
//  Created by Nick Kibysh on 13/12/2022.
//

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

