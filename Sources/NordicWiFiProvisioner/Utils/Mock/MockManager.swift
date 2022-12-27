//
//  File.swift
//  
//
//  Created by Nick Kibysh on 13/12/2022.
//

import CoreBluetoothMock

open class MockManager {
    public static let `default` = MockManager(devices: [
        MockDevice.notProvisioned,
        MockDevice.provisionedNotConnected,
        MockDevice.provisionedConnected
    ])
    public var devices: [MockDevice]
    
    public init(devices: [MockDevice]) {
        self.devices = devices
    }
    
    /// Start emulating scan results
    open func emulateDevices() {
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals(devices.map(\.spec))
        CBMCentralManagerMock.simulatePowerOn()
    }
}

