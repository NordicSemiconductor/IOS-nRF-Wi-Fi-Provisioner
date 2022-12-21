//
//  File.swift
//  
//
//  Created by Nick Kibysh on 13/12/2022.
//

import CoreBluetoothMock

open class MockManager {
    public static let `default` = MockManager()
    
    init() {
        
    }
    
    /// Start emulating scan results
    open func emulateDevices() {
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals([
            Device(
                name: "nRF-7",
                uuidString: "14387800-130c-49e7-b877-2881c89cb258",
                delegate: MockSpecDelegate(),
                version: 17,
                provisioned: true,
                connected: true,
                rssi: -50).spec
        ])
        CBMCentralManagerMock.simulatePowerOn()
    }
}

