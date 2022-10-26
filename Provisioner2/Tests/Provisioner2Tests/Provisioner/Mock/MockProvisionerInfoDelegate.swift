//
//  MockProvisionerInfoDelegate.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import Foundation
import Provisioner2

class MockProvisionerInfoDelegate: ProvisionerInfoDelegate {
    func versionReceived(_ version: Result<Int, Provisioner2.ProvisionerInfoError>) {
        self.version = version
    }
    
    func wifiStatusReceived(_ status: Result<Provisioner2.WiFiStatus, Provisioner2.ProvisionerError>) {
        self.wifiStatus = status
    }
    
    var version: Result<Int, ProvisionerInfoError>?
    var wifiStatus: Result<Provisioner2.WiFiStatus, Provisioner2.ProvisionerError>?
    
    
}
