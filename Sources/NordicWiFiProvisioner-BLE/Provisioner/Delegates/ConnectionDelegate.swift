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

/// A protocol that defines a delegate for Connection flow
public protocol ConnectionDelegate: AnyObject {
    /// Tells the delegate that the provisioner has connected to the device
    func deviceManagerConnectedDevice(_ deviceManager: DeviceManager)

    /// Tells the delegate that the provisioner was not able to connect to the device
    ///
    /// - Parameter error: Error that caused the connection failure
    func deviceManagerDidFailToConnect(_ deviceManager: DeviceManager, error: Error)

    /// Tells the delegate that the provisioner has disconnected from the device
    ///
    /// - Parameter error: If disconnected due to an issue, this parameter contains the error
    func deviceManagerDisconnectedDevice(_ deviceManager: DeviceManager, error: Error?)
    
    /// Tells the delegate that the provisioner changed its connection state
    ///
    /// - Parameter newState: New Connection State
    func deviceManager(_ deviceManager: DeviceManager, changedConnectionState newState: DeviceManager.ConnectionState)
}
