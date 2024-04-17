//
//  NWParameters+Extension.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 17/4/24.
//

import Foundation
import Network

extension NWParameters {
    
    static let discoveryParameters: NWParameters = {
        let parameters = NWParameters()
        parameters.expiredDNSBehavior = .allow
        if #available(iOS 16.0, *) {
            parameters.requiresDNSSECValidation = false
        }
        parameters.allowLocalEndpointReuse = true
        parameters.acceptLocalOnly = true
        parameters.allowFastOpen = true
        return parameters
    }()
}
