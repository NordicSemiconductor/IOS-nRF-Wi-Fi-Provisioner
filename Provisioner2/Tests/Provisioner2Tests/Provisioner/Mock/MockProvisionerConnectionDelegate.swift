//
//  File.swift
//  
//
//  Created by Nick Kibysh on 19/10/2022.
//

import Foundation
import CoreBluetoothMock
@testable import Provisioner2

class MockProvisionerConnectionDelegate: ProvisionerConnectionDelegate {
    func provisioner(_ provisioner: Provisioner, changedConnectionState newState: Provisioner.ConnectionState) {
        self.connectionState = newState
    }
    
    var connected = false
    var connectionError: Error?
    var connectionState: Provisioner.ConnectionState?
    
    func provisionerConnectedDevice(_ provisioner: Provisioner) {
        connected = true
        connectionError = nil 
    }
    
    func provisionerDidFailToConnect(_ provisioner: Provisioner, error: Error) {
        connectionError = error
    }
    
    func provisionerDisconnectedDevice(_ provisioner: Provisioner, error: Error?) {
        // TODO: Test
    }
}
