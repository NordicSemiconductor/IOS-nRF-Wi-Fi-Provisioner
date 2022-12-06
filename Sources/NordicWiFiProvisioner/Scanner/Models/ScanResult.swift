//
//  ScanResult.swift
//  
//
//  Created by Nick Kibysh on 10/10/2022.
//

import Foundation
import CoreBluetoothMock
import CryptoKit

/// Protocol which represents a discovered device
public protocol ScanResult {
    /// Device identifier (UUID String)
    var id: String { get }
    /// Device name
    var name: String { get }
    /// RSSI: Signal strength in dBm
    var rssi: Int { get }
    /// Returns true if the device already has the information about WiFi network
    var provisioned: Bool { get }
    /// Returns true if the device is currently connected to the WiFi network
    var connected: Bool { get }
    /// Version
    var version: Int? { get }
    /// WiFi-RSSI: Signal strength of Wi-Fi Access Point if the device is connected
    var wifiRSSI: Int? { get }
}

struct DiscoveredDevice: ScanResult, CustomStringConvertible {
    let peripheral: CBPeripheral
    let advertisementData: [String: Any]
    let serviceByteArray: [UInt8]?

    public let rssi: Int

    var provisioned: Bool {
        serviceByteArray.map { $0[2] & 0x01 == 1 } ?? false
    }

    var connected: Bool {
        serviceByteArray.map { $0[2] & 0x02 == 2 } ?? false
    }

    var name: String {
        peripheral.name ?? ""
    }

    var id: String {
        peripheral.identifier.uuidString
    }

    var version: Int? {
        serviceByteArray.flatMap { Int($0[0]) }
    }
    
    var wifiRSSI: Int? {
        serviceByteArray.flatMap { Int(Int8(bitPattern: $0[3])) }
    }

    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi.intValue
        
        self.serviceByteArray = advertisementData[CBAdvertisementDataServiceDataKey]
            .flatMap { $0 as? [CBUUID : Data] }
            .flatMap { $0[CBUUID(string: "14387800-130c-49e7-b877-2881c89cb258")] }
            .map { [UInt8]($0) }
    }

    var description: String {
        "name: \(name)|id: \(id)| rssi: \(rssi)| provisioned: \(provisioned)| connected: \(connected)| version: \(version ?? -1)| wifiRSSI: \(wifiRSSI ?? -1)"
    }
}
