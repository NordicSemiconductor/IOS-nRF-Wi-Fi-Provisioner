/*
* Copyright (c) 2022, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

public enum ProvisionerError: Error {
    /// Peripheral with provided deviceId is not found
    case noPeripheralFound
    /// Device is not connected
    case notConnected(Error)
    /// Bluetooth is not available
    case bluetoothNotAvailable
    
    case notSupported

    case unknown
    /// Data was received but unable to parse
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

    public var localizedDescription: String {
        switch self {
        case .noPeripheralFound:
            return "Peripheral with provided deviceId is not found"
        case .notConnected(let error):
            return "Device is not connected: \(error.localizedDescription)"
        case .bluetoothNotAvailable:
            return "Bluetooth is not available"
        case .notSupported:
            return "Not supported"
        case .unknown:
            return "Unknown error"
        case .badData:
            return "Data was received but unable to parse"
        case .deviceFailureResponse:
            return "Device failure response"
        case .emptyResponse:
            return "Response is successful but it's empty"
        case .invalidArgument:
            return "Request cannot be processed due to invalid arguments"
        case .failedToDecodeRequest:
            return "Failed to decode the request"
        case .internalError:
            return "Internal error"
        }
    }
}
