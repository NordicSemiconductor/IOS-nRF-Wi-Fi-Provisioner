//
// Created by Nick Kibysh on 05/08/2022.
//

import Provisioner

extension Provisioner.WiFiStatus: CustomStringConvertible {
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
        case .connectionFailed(_):
            return "Error"
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
}
