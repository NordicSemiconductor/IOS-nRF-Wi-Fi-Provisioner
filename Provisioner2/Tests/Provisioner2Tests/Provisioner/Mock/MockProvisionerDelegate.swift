//
//  File.swift
//  
//
//  Created by Nick Kibysh on 18/11/2022.
//

import Foundation
@testable import Provisioner2

class MockProvisionerDelegate: ProvisionerDelegate {
    
    var provisionerStarted: Bool = false
    var provisioner: Provisioner?
    var provisionerError: Error?
    
    var states: [Provisioner2.ConnectionState] = []
    var failReasons: [Provisioner2.ConnectionFailureReason] = []
    
    var provisionerUnset: Bool = false
    
    func provisionerDidSetConfig(provisioner: Provisioner2.Provisioner, error: Error?) {
        self.provisioner = provisioner
        self.provisionerError = error
        provisionerStarted = true
    }
    
    func provisioner(_ provisioner: Provisioner2.Provisioner, didChangeState state: Provisioner2.ConnectionState) {
        self.provisioner = provisioner
        self.states.append(state)
        
        if case .connectionFailed(let connectionFailureReason) = state {
            self.failReasons.append(connectionFailureReason)
        }
    }
    
    func provisionerDidUnsetConfig(provisioner: Provisioner2.Provisioner, error: Error?) {
        self.provisioner = provisioner
        self.provisionerError = error
        provisionerUnset = true
    }
}

