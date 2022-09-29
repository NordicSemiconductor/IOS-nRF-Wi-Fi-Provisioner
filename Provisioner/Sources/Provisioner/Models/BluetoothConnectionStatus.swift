//
// Created by Nick Kibysh on 28/09/2022.
//

import Foundation

public enum BluetoothConnectionStatus {
    case disconnected
    case connected
    case connecting
    case connectionCanceled(Reason)

    public enum Reason {
        case error(Swift.Error)
        case byRequest
    }
}
