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
import CoreBluetoothMock

/// UUIDs of the services used in the provisioning process.
public struct ServiceID {
    /// The Wi-Fi Provisioning Service identifier.
    ///
    /// Equal to `0x14387800-130c-49e7-b877-2881c89cb258`.
    public static let wifi = UUID(uuidString: "14387800-130c-49e7-b877-2881c89cb258")!
}

/// UUIDs of the characteristics used in the provisioning process.
public struct CharacteristicID {
    
    /// UUID of Version Information Characteristic.
    ///
    /// This characteristic describes the version of the current implementation of the Wi-Fi provisioning service.
    ///
    /// Equal to **`14387801-130c-49e7-b877-2881c89cb258`**.
    public static let version = UUID(uuidString: "14387801-130c-49e7-b877-2881c89cb258")!
    
    /// UUID of Operation Control Point Characteristic.
    ///
    /// Equal to **`14387802-130c-49e7-b877-2881c89cb258`**.
    public static let controlPoint = UUID(uuidString: "14387802-130c-49e7-b877-2881c89cb258")!
    
    /// UUID of Data Out Characteristic.
    ///
    /// This characteristic is used to send notifications to the client.
    ///
    /// Equal to **`14387803-130c-49e7-b877-2881c89cb258`**.
    public static let dataOut = UUID(uuidString: "14387803-130c-49e7-b877-2881c89cb258")!
}

