//
//  File.swift
//  
//
//  Created by Nick Kibysh on 19/10/2022.
//

import Foundation
import CoreBluetoothMock
@testable import Provisioner

class MockProvisionerConnectionDelegate: ProvisionerConnectionDelegate {
    func provisioner(_ provisioner: DeviceManager, changedConnectionState newState: DeviceManager.ConnectionState) {
        self.connectionState = newState
    }
    
    var connected = false
    var connectionError: Error?
    var connectionState: DeviceManager.ConnectionState?
    
    func provisionerConnectedDevice(_ provisioner: DeviceManager) {
        connected = true
        connectionError = nil 
    }
    
    func provisionerDidFailToConnect(_ provisioner: DeviceManager, error: Error) {
        connectionError = error
    }
    
    func provisionerDisconnectedDevice(_ provisioner: DeviceManager, error: Error?) {
        // TODO: Test
    }
}
