//
//  File.swift
//  
//
//  Created by Nick Kibysh on 19/10/2022.
//

import Foundation
import CoreBluetoothMock
@testable import Provisioner2

class MockProvisionerDelegate: ProvisionerConnectionDelegate {
    var connected = false
    var connectionError: Error?
    
    func deviceConnected() {
        connected = true
    }
    
    func deviceFailedToConnect(error: Error) {
        connectionError = error
    }
    
    func deviceDisconnected(error: Error?) {
        
    }
    
    func versionReceived(_ version: Int) {
        
    }
    
    func wifiStatusReceived(_ status: Provisioner2.WiFiStatus) {
        
    }
    
    
}
