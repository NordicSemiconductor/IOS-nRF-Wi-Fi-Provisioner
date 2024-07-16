//
// Created by Nick Kibysh on 02/09/2022.
//

import Foundation
import NordicWiFiProvisioner_BLE

// MARK: - ProvisionButtonState

extension DeviceView.ViewModel {
    
    struct ProvisionButtonState {
        var isEnabled: Bool
        var title: String
    }
}

// MARK: - PeripheralConnectionStatus

enum PeripheralConnectionStatus: CustomStringConvertible {
    
    case disconnected(Reason), connecting, connected, paired
    
    enum Reason {
        case byRequest, error(Error)
    }
    
    var status: StatusModifier.Status {
        switch self {
        case .disconnected:
            return .error
        case .paired:
            return .done
        case .connecting, .connected:
            return .inProgress
        }
    }
    
    public var isConnected: Bool {
        switch self {
        case .connected:
            return true
        default:
            return false
        }
    }
    
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
        case .paired:
            return "Paired"
        }
    }
}

// MARK: - WiFiConnectionStatus

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
}

// MARK: - ButtonsConfig

extension DeviceView.ViewModel {
    
    struct ButtonsConfig {
        var showUnsetButton: Bool
        var enabledUnsetButton: Bool

        var provisionButtonTitle: String
        var enabledProvisionButton: Bool
        
        init(showUnsetButton: Bool = false, enabledUnsetButton: Bool = true, provisionButtonTitle: String = "Set", enabledProvisionButton: Bool = false) {
            self.showUnsetButton = showUnsetButton
            self.enabledUnsetButton = enabledUnsetButton
            self.provisionButtonTitle = provisionButtonTitle
            self.enabledProvisionButton = enabledProvisionButton
        }
    }
}
