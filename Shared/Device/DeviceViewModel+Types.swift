//
// Created by Nick Kibysh on 02/09/2022.
//

import Foundation
import NordicStyle
import Provisioner

extension DeviceViewModel {
    struct ProvisionButtonState {
        var isEnabled: Bool
        var title: String
        var style: NordicButtonStyle
    }

    enum ConnectionState: CustomStringConvertible {
        case disconnected
        case connecting
        case failed(ReadableError)
        case connected

        var description: String {
            switch self {
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting ..."
            case .failed(let e):
                return e.message
            case .connected:
                return "Connected"
            }
        }
    }
}

extension BluetoothConnectionStatus {
    func toConnectionState() -> DeviceViewModel.ConnectionState {
        switch self {
        case .disconnected:
            return .disconnected
        case .connected:
            return .connected
        case .connecting:
            return .connecting
        case .connectionCanceled(let reason):
            switch reason {
            case .error(let e):
                return .failed(TitleMessageError(title: "Something went wrong", message: e.localizedDescription))
            case .byRequest:
                return .disconnected
            }
        }
    }
}

extension BluetoothConnectionStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting ..."
        case .connectionCanceled(let reason):
            switch reason {
            case .error(let e):
                return e.localizedDescription
            case .byRequest:
                return "Disconnected"
            }
        }
    }
}
