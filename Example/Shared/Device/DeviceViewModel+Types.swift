//
// Created by Nick Kibysh on 02/09/2022.
//

import Foundation
import NordicStyle

extension DeviceView.ViewModel {
    struct ProvisionButtonState {
        var isEnabled: Bool
        var title: String
    }
}

enum PeripheralConnectionStatus {
    enum Reason {
        case byRequest, error(Error)
    }
    case disconnected(Reason), connected, connecting
}

extension PeripheralConnectionStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected(let reason):
            switch reason {
            case .error(let e):
                return e.localizedDescription
            case .byRequest:
                return "Disconnected"
            }
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting ..."
        }
    }
}

extension DeviceView.ViewModel {
    struct WiFiConnectionStatus {
        var status: String
        var statusProgressState: StatusModifier.Status
        var showStatus: Bool
        var ipAddress: String
        var showIpAddress: Bool
        
        init(status: String = "", statusProgressState: StatusModifier.Status = .ready, showStatus: Bool = false, ipAddress: String = "", showIpAddress: Bool = false) {
            self.status = status
            self.statusProgressState = statusProgressState
            self.showStatus = showStatus
            self.ipAddress = ipAddress
            self.showIpAddress = showIpAddress
        }
    }

    struct WiFiNetwork {
        var ssid: String
        var channel: UInt?
        var bssid: String?
        var band: String?
        var security: String?
        var enabled: Bool

        var showPassword: Bool

        var volatileMemory: Bool
        var showVolatileMemory: Bool
        
        init(ssid: String = "Not Selected", bssid: String? = nil, channel: UInt? = nil, security: String? = nil, enabled: Bool = true, showPassword: Bool = false, volatileMemory: Bool = true, showVolatileMemory: Bool = false) {
            self.ssid = ssid
            self.bssid = bssid
            self.channel = channel
            self.security = security
            self.enabled = enabled
            self.showPassword = showPassword
            self.volatileMemory = volatileMemory
            self.showVolatileMemory = showVolatileMemory
        }
    }

    struct ButtonsConfig {
        var showUnsetButton: Bool
        var enabledUnsetButton: Bool

        var provisionButtonTitle: String
        var enabledProvisionButton: Bool
        
        init(showUnsetButton: Bool = false, enabledUnsetButton: Bool = true, provisionButtonTitle: String = "Set Configuration", enabledProvisionButton: Bool = false) {
            self.showUnsetButton = showUnsetButton
            self.enabledUnsetButton = enabledUnsetButton
            self.provisionButtonTitle = provisionButtonTitle
            self.enabledProvisionButton = enabledProvisionButton
        }
    }
}
