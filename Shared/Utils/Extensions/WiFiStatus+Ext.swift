//
// Created by Nick Kibysh on 05/08/2022.
//

import Provisioner

extension WiFiStatus: CustomStringConvertible {
    var isInProgress: Bool {
        switch self {
        case .disconnected, .connectionFailed, .connected:
            return false
        case .authentication, .association, .obtainingIp:
            return true
        }
    }

    public var description: String {
        switch self {
        case .connectionFailed(let e):
            return conventError(e)
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .authentication:
            return "Authentication"
        case .association:
            return "Association"
        case .obtainingIp:
            return "Obtaining IP"
        }
    }

    private func conventError(_ error: WiFiStatus.ConnectionFailure) -> String {
        switch error {
        case .authError:
            return "Authentication error"
        case .networkNotFound:
            return "Network not found"
        case .timeout:
            return "Timeout"
        case .failIp:
            return "Failed to obtain IP"
        case .failConn:
            return "Failed to connect"
        case .unknown:
            return "Unknown error"
        }
    }
}
