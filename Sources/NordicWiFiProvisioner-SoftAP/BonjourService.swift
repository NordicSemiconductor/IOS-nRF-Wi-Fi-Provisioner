//
//  BonjourService.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 29/4/24.
//

import Foundation
import Network

// MARK: - BonjourService

public struct BonjourService: Sendable {
    
    // MARK: Properties
    
    let name: String
    let domain: String
    let type: String
    
    // MARK: Init
    
    init(netService: NetService) {
        self.init(name: netService.name, domain: netService.domain, type: netService.type)
    }
    
    public init (name: String, domain: String, type: String) {
        self.name = name
        self.domain = domain
        self.type = type
    }
    
    // MARK: Internal API
    
    func descriptor() -> NWBrowser.Descriptor {
        return .bonjour(type: type, domain: domain)
    }
    
    func netService() -> NetService {
        NetService(domain: domain, type: type, name: name)
    }
}

// MARK: - BonjourError

public enum BonjourError: Error, LocalizedError {
    
    case stoppedByUser
    case unableToResolve(reason: String)
    case noAddressFound
    case unableToParseSocketAddress
}
