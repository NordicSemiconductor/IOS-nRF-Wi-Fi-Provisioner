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
import CryptoKit

/// Struct which represents a discovered device
public struct ScanResult {
    /// Device identifier
    public var id: UUID
    /// Device name
    public var name: String
    /// RSSI: Signal strength in dBm
    public var rssi: Int
    /// Returns true if the device already has the information about WiFi network
    public var provisioned: Bool
    /// Returns true if the device is currently connected to the WiFi network
    public var connected: Bool
    /// Version
    public var version: Int?
    /// WiFi-RSSI: Signal strength of Wi-Fi Access Point if the device is connected
    public var wifiRSSI: Int?
    
    public init(id: UUID, name: String, rssi: Int, provisioned: Bool, connected: Bool, version: Int? = nil, wifiRSSI: Int? = nil) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.provisioned = provisioned
        self.connected = connected
        self.version = version
        self.wifiRSSI = wifiRSSI
    }
}

extension ScanResult {
    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        
        let serviceByteArray: [UInt8]? = advertisementData[CBAdvertisementDataServiceDataKey]
            .flatMap { $0 as? [CBUUID : Data] }
            .flatMap { $0[CBUUID(string: "14387800-130c-49e7-b877-2881c89cb258")] }
            .map { [UInt8]($0) }
        
        self.id = peripheral.identifier
        self.name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? ""
        self.rssi = rssi.intValue
        self.provisioned = serviceByteArray.map { $0[2] & 0x01 == 1 } ?? false
        self.connected = serviceByteArray.map { $0[2] & 0x02 == 2 } ?? false
        self.version = serviceByteArray.flatMap { Int($0[0]) }
        self.wifiRSSI = serviceByteArray.flatMap { Int(Int8(bitPattern: $0[3])) }
    }
}
