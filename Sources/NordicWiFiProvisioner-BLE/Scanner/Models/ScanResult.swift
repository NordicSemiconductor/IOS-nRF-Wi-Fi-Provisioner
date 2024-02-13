//
//  ScanResult.swift
//  
//
//  Created by Nick Kibysh on 10/10/2022.
//

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
