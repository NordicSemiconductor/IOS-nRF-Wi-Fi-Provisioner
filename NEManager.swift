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

    // MARK: Init
    
    public init() {}
    
    // MARK: API
    
    public func apply(_ configuration: NEHotspotConfiguration) async throws {
        let manager = NEHotspotConfigurationManager.shared
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
                throw error
            }
            
            switch configurationError {
            case .alreadyAssociated, .pending:
                // swallow Error.
                break
            default:
                throw error
            }
        }
    }
}
