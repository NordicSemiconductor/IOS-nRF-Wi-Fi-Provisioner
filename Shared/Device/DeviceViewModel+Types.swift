//
// Created by Nick Kibysh on 02/09/2022.
//

import Foundation
import NordicStyle

extension DeviceView.ViewModel {
    struct ProvisionButtonState {
        var isEnabled: Bool
        var title: String
        var style: NordicButtonStyle
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
