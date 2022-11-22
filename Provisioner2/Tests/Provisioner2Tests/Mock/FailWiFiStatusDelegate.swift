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
    
    override func response(deviceStatus: Proto.DeviceStatus? = nil, status: Proto.Status? = .success, requestCode: Proto.OpCode) -> Data {
        if let status = self.failure {
            var response = Proto.Response()
            response.status = status
            response.requestOpCode = .getStatus
            if let deviceStatus {
                response.deviceStatus = deviceStatus
            }
            
            return try! response.serializedData()
        } else {
            return super.response(deviceStatus: deviceStatus, status: status, requestCode: requestCode)
        }
    }
}
