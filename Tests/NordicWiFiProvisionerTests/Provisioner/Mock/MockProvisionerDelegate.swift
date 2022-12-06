//
//  File.swift
//  
//
//  Created by Nick Kibysh on 18/11/2022.
//

import Foundation
@testable import NordicWiFiProvisioner

class MockProvisionerDelegate: ProvisionDelegate {
    
    var provisionerStarted: Bool = false
    var provisioner: DeviceManager?
    var provisionerError: Error?
    
    var states: [NordicWiFiProvisioner.ConnectionState] = []
    var failReasons: [NordicWiFiProvisioner.ConnectionFailureReason] = []
    
    var provisionerUnset: Bool = false
    
    func deviceManagerDidSetConfig(_ deviceManager: DeviceManager, error: Error?) {
        self.provisioner = deviceManager
        self.provisionerError = error
        provisionerStarted = true
    }
    
    func deviceManager(_ provisioner: NordicWiFiProvisioner.DeviceManager, didChangeState state: NordicWiFiProvisioner.ConnectionState) {
        self.provisioner = provisioner
        self.states.append(state)
        
        if case .connectionFailed(let connectionFailureReason) = state {
            self.failReasons.append(connectionFailureReason)
        }
    }
    
    func deviceManagerDidForgetConfig(_ deviceManager: DeviceManager, error: Error?) {
        self.provisioner = deviceManager
        self.provisionerError = error
        provisionerUnset = true
    }
}

