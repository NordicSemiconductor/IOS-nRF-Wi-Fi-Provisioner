//
// Created by Nick Kibysh on 31/08/2022.
//

import Foundation

/// Common error type for all the errors that can be thrown by the library.
public protocol ProvisionerError: Swift.Error {

}

/// Bluetooth Errors
public enum BluetoothConnectionError: ProvisionerError {
    case wifiServiceNotFound
    case versionCharacteristicNotFound
    case controlCharacteristicPointNotFound
    case dataOutCharacteristicNotFound
    case canNotConnect
    case commonError(error: Error)
    case unknownError
}

/// Provisioner Errors
public enum ProvisionError: ProvisionerError {
    case canNotConnect
    case requestFailed
    case noResponse
    case unknownDeviceStatus

    case stopScanFailed
}