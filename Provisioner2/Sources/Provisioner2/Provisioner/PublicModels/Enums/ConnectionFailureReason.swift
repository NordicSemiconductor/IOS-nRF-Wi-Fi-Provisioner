//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

public enum ConnectionFailureReason: Error, Equatable {
    
    /// Authentication error.
    case authError
    
    /// The specified network could not be find.
    case networkNotFound
    
    /// Timeout occurred.
    case timeout
    
    /// Could not obtain IP from provided provisioning information.
    case failIp
    
    /// Could not connect to provisioned network.
    case failConn
    
    /// If the device doesn't send any reason `unknown` will be set.
    case unknown
}

extension ConnectionFailureReason: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authError:
            return "Authentication error"
        case .networkNotFound:
            return "Network not found"
        case .timeout:
            return "Timeout"
        case .failIp:
            return "Could not obtain IP"
        case .failConn:
            return "Could not connect to provisioned network"
        case .unknown:
            return "Unknown failure reason"
        }
    }
}

extension ConnectionFailureReason: ProtoConvertible {
    init(proto: Proto.ConnectionFailureReason) {
        switch proto {
        case .authError:
            self = .authError
        case .networkNotFound:
            self = .networkNotFound
        case .timeout:
            self = .timeout
        case .failIp:
            self = .failIp
        case .failConn:
            self = .failConn
        }
    }
    
    var proto: Proto.ConnectionFailureReason {
        switch self {
        case .authError:
            return .authError
        case .networkNotFound:
            return .networkNotFound
        case .timeout:
            return .timeout
        case .failIp:
            return .failIp
        case .failConn:
            return .failConn
        case .unknown:
            fatalError("There's no such reason on the device")
        }
    }
}

