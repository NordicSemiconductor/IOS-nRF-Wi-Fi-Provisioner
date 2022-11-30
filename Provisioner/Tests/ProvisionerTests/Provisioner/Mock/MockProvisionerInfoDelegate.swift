//
//  MockProvisionerInfoDelegate.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import Foundation
import Provisioner

class MockProvisionerInfoDelegate: InfoDelegate {
    func deviceStatusReceived(_ status: Result<Provisioner.DeviceStatus, Provisioner.ProvisionerError>) {
        self.deviceStatus = status
    }
    
    func versionReceived(_ version: Result<Int, Provisioner.ProvisionerInfoError>) {
        self.version = version
    }
    
    var version: Result<Int, ProvisionerInfoError>?
    var deviceStatus: Result<Provisioner.DeviceStatus, ProvisionerError>?
    
    
}
