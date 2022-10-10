//
// Created by Nick Kibysh on 01/09/2022.
//

import Foundation
import CoreBluetoothMock

extension CBManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .resetting:
            return "Resetting"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "Powered Off"
        case .poweredOn:
            return "Powered On"
        }
    }
}
