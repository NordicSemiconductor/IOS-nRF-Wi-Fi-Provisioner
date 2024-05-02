//
//  NEManager.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 29/4/24.
//

import Foundation
import Network
import NetworkExtension

// MARK: - NEManager

public struct NEManager {

    public var delegate: ProvisionManager.Delegate?
    
    // MARK: Init
    
    public init() {}
    
    // MARK: API
    
    public func apply(_ configuration: NEHotspotConfiguration) async throws {
        let manager = NEHotspotConfigurationManager.shared
        delegate?.log("Applying Network Configuration...", level: .info)
        try await switchWiFiEndpoint(using: manager, with: configuration)
    }
    
    // MARK: Private
    
    private func switchWiFiEndpoint(using manager: NEHotspotConfigurationManager,
                                    with configuration: NEHotspotConfiguration) async throws {
        do {
            try await manager.apply(configuration)
        } catch {
            let nsError = error as NSError
            guard nsError.domain == NEHotspotConfigurationErrorDomain,
                  let configurationError = NEHotspotConfigurationError(rawValue: nsError.code) else {
                delegate?.log(error.localizedDescription, level: .error)
                throw error
            }
            
            switch configurationError {
            case .alreadyAssociated:
                delegate?.log("Network Configuration change is not necessary. Configuration is alredy associated.", level: .info)
                // swallow Error.
                break
            case .pending:
                delegate?.log("Waiting for Configuration change to take place...", level: .debug)
                // swallow Error.
                break
            case .userDenied:
                delegate?.log("User Denied Network change request", level: .fault)
                fallthrough
            default:
                throw error
            }
        }
    }
}
