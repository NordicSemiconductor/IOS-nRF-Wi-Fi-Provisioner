//
//  DeviceStates+Ext.swift
//  
//
//  Created by Nick Kibysh on 25/07/2022.
//

import Foundation

extension ConnectionState {
    func toPublicStatus(withReason reason: ConnectionFailureReason? = nil) -> WiFiStatus {
        switch self {
        case .connected: return .connected
        case .association: return .association
        case .authentication: return .authentication
        case .connectionFailed: return .connectionFailed(reason?.toPublicStatus() ?? .unknown)
        case .disconnected: return .disconnected
        case .obtainingIp: return .obtainingIp
        }
    }
}

extension ConnectionFailureReason {
    func toPublicStatus() -> WiFiStatus.ConnectionFailure {
        switch self {
        case .authError: return .authError
        case .failConn: return .failConn
        case .failIp: return .failIp
        case .networkNotFound: return .networkNotFound
        case .timeout: return .timeout
        }
    }
}
