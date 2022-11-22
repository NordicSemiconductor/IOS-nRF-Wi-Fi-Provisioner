//
//  File.swift
//  
//
//  Created by Nick Kibysh on 18/11/2022.
//

import Foundation

public enum ProvisionerError: Error {
    /// Provided device id is not valid
    case badIdentifier
    /// Peripheral with provided deviceId is not found
    case noPeripheralFound
    /// Device is not connected
    case notConnected(Error)
    /// Bluetooth is not available
    case bluetoothNotAvailable
    
    case notSupported

    case unknown
    /// Data was received but unnable to parse
    case badData
    /// Device failure response
    case deviceFailureResponse
    /// Response is successful but it's empty
    case emptyResponse

    /// Returned when the request cannot be processed due to invalid arguments.
    /// For example, if the required argument is missing.
    case invalidArgument

    /// Returned when failed to decode the request.
    case failedToDecodeRequest

    /// Returned in case of internal error. Hopefully never.
    case internalError
}
