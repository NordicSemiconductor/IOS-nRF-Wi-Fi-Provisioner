//
//  File.swift
//  
//
//  Created by Nick Kibysh on 31/10/2022.
//

import Foundation

@testable import Provisioner2

class FailWifiStatusDelegate: WifiDeviceDelegate {
    let failure: Proto.Status?
    
    init(failure: Proto.Status?) {
        self.failure = failure
    }
    
    override func wifiStatus(_ stt: Proto.ConnectionState) -> Data {
        if let status = self.failure {
            var response = Proto.Response()
            response.status = status
            response.requestOpCode = .getStatus
            var deviceStatus = Proto.DeviceStatus()
            deviceStatus.state = stt
            deviceStatus.provisioningInfo = wifiInfo()
            
            return try! response.serializedData()
        } else {
            return super.wifiStatus(stt)
        }
    }
}
