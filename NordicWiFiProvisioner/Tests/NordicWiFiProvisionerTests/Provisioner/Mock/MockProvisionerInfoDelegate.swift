//
//  MockProvisionerInfoDelegate.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import Foundation
import NordicWiFiProvisioner

class MockProvisionerInfoDelegate: InfoDelegate {
    func deviceStatusReceived(_ status: Result<NordicWiFiProvisioner.DeviceStatus, NordicWiFiProvisioner.ProvisionerError>) {
        self.deviceStatus = status
    }
    
    func versionReceived(_ version: Result<Int, NordicWiFiProvisioner.ProvisionerInfoError>) {
        self.version = version
    }
    
    var version: Result<Int, ProvisionerInfoError>?
    var deviceStatus: Result<NordicWiFiProvisioner.DeviceStatus, ProvisionerError>?
    
    
}
