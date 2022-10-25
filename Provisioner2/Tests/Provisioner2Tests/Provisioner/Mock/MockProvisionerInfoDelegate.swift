//
//  MockProvisionerInfoDelegate.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import Foundation
import Provisioner2

class MockProvisionerInfoDelegate: ProvisionerInfoDelegate {
    var version: Int?
    var wifiStatus: WiFiStatus?
    
    func versionReceived(_ version: Int) {
        self.version = version
    }
    
    func wifiStatusReceived(_ status: Provisioner2.WiFiStatus) {
        self.wifiStatus = status
    }
    
    
}
