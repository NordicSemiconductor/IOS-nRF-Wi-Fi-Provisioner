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
        return .bonjourWithTXTRecord(type: type, domain: domain)
    }
    
    func netService() -> NetService {
        NetService(domain: domain, type: type, name: name)
    }
}

// MARK: - BonjourError

public enum BonjourError: Error, LocalizedError {
    
    case stoppedByUser
    case unableToResolve(reason: String)
    case serviceNotFound
    case noAddressFound
    case unableToParseSocketAddress
    
    public var errorDescription: String? {
        localizedDescription
    }
    
    public var failureReason: String? {
        localizedDescription
    }
    
    public var localizedDescription: String {
        switch self {
        case .stoppedByUser:
            "Bonjour Browser stopped by user"
        case .unableToResolve(reason: let reason):
            "Unable to resolve IP Address: \(reason)"
        case .serviceNotFound:
            "Bonjour Service not found"
        case .noAddressFound:
            "IP Address not found in Bonjour Service result"
        case .unableToParseSocketAddress:
            "IP data found for Bonjour Service, but failed to parse it into a proper address."
        }
    }
}
