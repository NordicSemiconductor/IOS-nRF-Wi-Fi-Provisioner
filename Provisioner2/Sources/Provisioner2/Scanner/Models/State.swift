//
// Created by Nick Kibysh on 07/10/2022.
//

import Foundation
import CoreBluetoothMock

extension Scanner {

    public enum State {
        case poweredOn
        case poweredOff
        case resetting
        case unauthorized
        case unknown
        case unsupported

        init(_ state: CBManagerState) {
            switch state {
            case .poweredOn:
                self = .poweredOn
            case .poweredOff:
                self = .poweredOff
            case .resetting:
                self = .resetting
            case .unauthorized:
                self = .unauthorized
            case .unknown:
                self = .unknown
            case .unsupported:
                self = .unsupported
            }
        }
    }
}
