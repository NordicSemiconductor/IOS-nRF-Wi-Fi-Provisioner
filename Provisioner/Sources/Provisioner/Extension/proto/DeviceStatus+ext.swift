//
//  File.swift
//  
//
//  Created by Nick Kibysh on 25/07/2022.
//

import Foundation

extension DeviceStatus {
    func toPublicStatus() -> Provisioner.WiFiStatus {
        switch self.state {
        case .connected: return .connected
        case .association: return .association
        case .authentication: return .authentication
        case .connectionFailed: return .connectionFailed(self.reason.toPublicStatus())
        case .disconnected: return .disconnected
        case .obtainingIp: return .obtainingIp
        }
    }
}

extension ConnectionFailureReason {
    func toPublicStatus() -> Provisioner.WiFiStatus.ConnectionFailure {
        switch self {
        case .authError: return .authError
        case .failConn: return .failConn
        case .failIp: return .failIp
        case .networkNotFound: return .networkNotFound
        case .timeout: return .timeout
        }
    }
}
