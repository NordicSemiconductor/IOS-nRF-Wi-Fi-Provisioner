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

/// A protocol that defines a delegate for retrieving Wi-Fi scan results.
public protocol WiFiScannerDelegate: AnyObject {
    /// Called when the new Wi-Fi scan result is received.
    ///
    /// - parameter wifi: The Wi-Fi Info.
    /// - parameter rssi: The RSSI value. The value is in dBm.
    func deviceManager(_ deviceManager: DeviceManager, discoveredAccessPoint wifi: WifiInfo, rssi: Int?)
    
    /// Notify delegate that scanning for Access Points started
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occurred.
    func deviceManagerDidStartScan(_ deviceManager: DeviceManager, error: Error?)
    
    /// Notify delegate that scanning for Access Points started
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occurred.
    func deviceManagerDidStopScan(_ deviceManager: DeviceManager, error: Error?)
}
