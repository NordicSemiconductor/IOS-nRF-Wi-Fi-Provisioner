//
//  CentralManager.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 11/07/2022.
//

import Combine
import CoreBluetoothMock
import Foundation
import os

extension BluetoothManager {
    struct ScanResult: Hashable {
        let peripheral: CBPeripheral
        let rssi: Int
        let advertisementData: [String: Any]

        var name: String {
            peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "n/a"
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(peripheral.identifier)
        }
    }
}

class BluetoothManager: NSObject {
    var statePublisher: AnyPublisher<CBManagerState, Error> {
        stateSubject.eraseToAnyPublisher()
    }

    var peripheralPublisher: AnyPublisher<ScanResult, Error> {
        peripheralSubject.eraseToAnyPublisher()
    }

    private let stateSubject = PassthroughSubject<CBManagerState, Error>.init()
    private let peripheralSubject = PassthroughSubject<ScanResult, Error>.init()

    private let centralManager: CBCentralManager

    private let logger = Logger(
            subsystem: Bundle(for: BluetoothManager.self).bundleIdentifier ?? "",
            category: "scanner.bluetooth-manager"
    )

    init(centralManager: CBCentralManager) {
        self.centralManager = centralManager
        super.init()
        self.centralManager.delegate = self
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "14387800-130c-49e7-b877-2881c89cb258")])
    }

    override init() {
        centralManager = CBCentralManagerFactory.instance()
        super.init()
        centralManager.delegate = self
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)
        logger.debug("centralManagerDidUpdateState: \(central.state.debugDescription)")
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "14387800-130c-49e7-b877-2881c89cb258")])
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let scanResult = ScanResult(
                peripheral: peripheral,
                rssi: RSSI.intValue,
                advertisementData: advertisementData
        )
        peripheralSubject.send(scanResult)
        logger.debug("didDiscover peripheral: \(scanResult.debugDescription)")
    }
}

extension BluetoothManager.ScanResult: CustomDebugStringConvertible {
    var debugDescription: String {
        "ScanResult(peripheral: \(peripheral.identifier.uuidString), rssi: \(rssi), advertisementData: \(advertisementData))"
    }
}

extension BluetoothManager.ScanResult: Equatable {
    static func == (lhs: BluetoothManager.ScanResult, rhs: BluetoothManager.ScanResult) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier && lhs.rssi == rhs.rssi
    }
}

extension CBManagerState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unsupported:
            return "unsupported"
        case .unknown:
            return "unknown"
        @unknown default:
            return "unknown"
        }
    }
}