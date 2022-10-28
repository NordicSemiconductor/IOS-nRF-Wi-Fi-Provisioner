//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

public enum ConnectionState {
    case disconnected
    case authentication
    case association
    case obtainingIp
    case connected
    case connectionFailed
}

extension ConnectionState: ProtoConvertible {
    init(proto: Proto.ConnectionState) {
        switch proto {
        case .disconnected:
            self = .disconnected
        case .authentication:
            self = .authentication
        case .association:
            self = .association
        case .obtainingIp:
            self = .obtainingIp
        case .connected:
            self = .connected
        case .connectionFailed:
            self = .connectionFailed
        }
    }
    
    var proto: Proto.ConnectionState {
        switch self {
        case .disconnected:
            return .disconnected
        case .authentication:
            return .authentication
        case .association:
            return .association
        case .obtainingIp:
            return .obtainingIp
        case .connected:
            return .connected
        case .connectionFailed:
            return .connectionFailed
        }
    }
}
