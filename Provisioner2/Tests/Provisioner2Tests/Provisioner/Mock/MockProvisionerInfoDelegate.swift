//
//  MockProvisionerInfoDelegate.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import Foundation
import Provisioner2

class MockProvisionerInfoDelegate: ProvisionerInfoDelegate {
    func deviceStatusReceived(_ status: Result<Provisioner2.DeviceStatus, Provisioner2.ProvisionerError>) {
        self.deviceStatus = status
    }
    
    func versionReceived(_ version: Result<Int, Provisioner2.ProvisionerInfoError>) {
        self.version = version
    }
    
    var version: Result<Int, ProvisionerInfoError>?
    var deviceStatus: Result<Provisioner2.DeviceStatus, ProvisionerError>?
    
    
}
