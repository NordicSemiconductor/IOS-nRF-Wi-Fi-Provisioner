//
//  File.swift
//  
//
//  Created by Nick Kibysh on 13/12/2022.
//

import CoreBluetoothMock

/// Mock manager emulates nRF-7 devices and the whole process of provisioning.
open class MockManager {
    /// Default mock manager with 3 devices: not provisioned, provisioned but not connected, provisioned and connected.
    public static let `default` = MockManager(devices: [
        MockDevice.notProvisioned,
        MockDevice.provisionedNotConnected,
        MockDevice.provisionedConnected
    ])

    /// List of devices to emulate
    public var devices: [MockDevice]
    
    /// Initialize mock manager with devices to emulate
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

