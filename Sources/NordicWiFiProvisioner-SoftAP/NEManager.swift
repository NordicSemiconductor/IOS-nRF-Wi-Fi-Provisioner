/*
* Copyright (c) 2024, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import Network
import NetworkExtension

// MARK: - NEManager

public struct NEManager {

    public var delegate: ProvisionManager.Delegate?
    
    // MARK: Init
    
    public init() {}
    
    // MARK: API
    
    /**
     Warning: This function might return without throwing any Error if the Network Change fails. This is because iOS will inform the user via Dialog, but we will never get said Error in the callback. Nothing we can do about it.
     */
    public func apply(_ configuration: NEHotspotConfiguration) async throws {
        let manager = NEHotspotConfigurationManager.shared
        delegate?.log("Applying Network Configuration change to \(configuration.ssid)...", level: .info)
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
                throw error
            case .internal:
                delegate?.log("Internal Error \(error.localizedDescription)", level: .fault)
                throw error
            case .invalid:
                delegate?.log("Invalid Configuration is being applied", level: .fault)
                throw error
            case .invalidEAPSettings:
                delegate?.log("Invalid EAP Settings", level: .fault)
                throw error
            case .invalidSSID:
                delegate?.log("Invalid SSID", level: .fault)
                throw error
            case .invalidWEPPassphrase:
                delegate?.log("Invalid WEP Passphrase / Password", level: .fault)
                throw error
            case .invalidWPAPassphrase:
                delegate?.log("Invalid WPA Passphrase / Password", level: .fault)
                throw error
            default:
                delegate?.log("Undefined Error: \(error.localizedDescription)", level: .fault)
                throw error
            }
        }
    }
}
