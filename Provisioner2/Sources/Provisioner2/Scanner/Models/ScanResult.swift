//
//  ScanResult.swift
//  
//
//  Created by Nick Kibysh on 10/10/2022.
//

import Foundation
import CoreBluetoothMock

/// Protocol which represents a discovered device
public protocol ScanResult {
    /// Device identifier (UUID String)
    var id: String { get }
    /// Device name
    var name: String { get }
    /// Returns true if the device already has the information about WiFi network
    var provisioned: Bool { get }
    /// Version
    var version: Int? { get }
    /// RSSI: Signal strength in dBm
    var rssi: Int { get }
}

struct DiscoveredDevice: ScanResult {
    let peripheral: CBPeripheral
    let advertisementData: [String: Any]

    public let rssi: Int

    var provisioned: Bool {
        return false
    }

    var name: String {
        return peripheral.name ?? ""
    }

    var id: String {
        return peripheral.identifier.uuidString
    }

    var version: Int? {
        return 0
    }

    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi.intValue
    }
}
