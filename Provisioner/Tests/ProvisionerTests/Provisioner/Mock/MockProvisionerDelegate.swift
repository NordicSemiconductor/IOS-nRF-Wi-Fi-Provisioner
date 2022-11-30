//
//  File.swift
//  
//
//  Created by Nick Kibysh on 18/11/2022.
//

import Foundation
@testable import Provisioner

class MockProvisionerDelegate: ProvisionerDelegate {
    
    var provisionerStarted: Bool = false
    var provisioner: DeviceManager?
    var provisionerError: Error?
    
    var states: [Provisioner.ConnectionState] = []
    var failReasons: [Provisioner.ConnectionFailureReason] = []
    
    var provisionerUnset: Bool = false
    
    func provisionerDidSetConfig(provisioner: Provisioner.DeviceManager, error: Error?) {
        self.provisioner = provisioner
        self.provisionerError = error
        provisionerStarted = true
    }
    
    func provisioner(_ provisioner: Provisioner.DeviceManager, didChangeState state: Provisioner.ConnectionState) {
        self.provisioner = provisioner
        self.states.append(state)
        
        if case .connectionFailed(let connectionFailureReason) = state {
            self.failReasons.append(connectionFailureReason)
        }
    }
    
    func provisionerDidUnsetConfig(provisioner: Provisioner.DeviceManager, error: Error?) {
        self.provisioner = provisioner
        self.provisionerError = error
        provisionerUnset = true
    }
}

