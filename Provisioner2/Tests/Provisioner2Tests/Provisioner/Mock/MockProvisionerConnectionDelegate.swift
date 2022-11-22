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
    func connectionStateChanged(_ newState: Provisioner2.Provisioner.ConnectionState) {
        self.connectionState = newState
    }
    
    var connected = false
    var connectionError: Error?
    var connectionState: Provisioner.ConnectionState?
    
    func deviceConnected() {
        connected = true
        connectionError = nil 
    }
    
    func deviceFailedToConnect(error: Error) {
        connectionError = error
    }
    
    func deviceDisconnected(error: Error?) {
        // TODO: Test
    }
}
