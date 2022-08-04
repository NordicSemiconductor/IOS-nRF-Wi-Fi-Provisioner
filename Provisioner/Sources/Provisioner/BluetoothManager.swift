//
// Created by Nick Kibysh on 02/08/2022.
//

import Foundation
import CoreBluetoothMock
import Combine
import os

extension CentralManager {
    enum Error: Swift.Error {
        case peripheralNotFound
        case timeout
        case noValue
    }
}

private struct Service {
    static let wifi = CBMUUID(string: "14387800-130c-49e7-b877-2881c89cb258")

    struct Characteristic {
        static let version = CBMUUID(string: "14387801-130c-49e7-b877-2881c89cb258")
        static let controlPoint = CBMUUID(string: "14387802-130c-49e7-b877-2881c89cb258")
        static let dataOut = CBMUUID(string: "14387803-130c-49e7-b877-2881c89cb258")
    }
}

private struct CharacteristicValueContinuation: Identifiable, Hashable {
    var id: CBMUUID {
        characteristic.uuid
    }

    static func ==(lhs: CharacteristicValueContinuation, rhs: CharacteristicValueContinuation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let continuation: CheckedContinuation<Data, Error>
    let characteristic: CBMCharacteristic
}

class CentralManager {
    let centralManager: CBMCentralManager
    private let logger = Logger(
            subsystem: Bundle(for: Provisioner.self).bundleIdentifier ?? "",
            category: "provisioner-central-manager"
    )

    private var connectedPeripheral: CBMPeripheral?
    private var connectionContinuation: CheckedContinuation<CBMPeripheral, Swift.Error>?

    private var wifiService: CBMService!
    private (set) var versionCharacteristic: CBMCharacteristic!
    private (set) var controlPointCharacteristic: CBMCharacteristic!
    private (set) var dataOutCharacteristic: CBMCharacteristic!

    private var readValueContinuations: Set<CharacteristicValueContinuation> = []
    private var identifiableContinuations: Set<CharacteristicValueContinuation> = []
    private var valueStreams: [CBMCharacteristic: PassthroughSubject<Data?, Swift.Error>] = [:]

    init(centralManager: CBMCentralManager = CBMCentralManagerFactory.instance()) {
        self.centralManager = centralManager
    }
}

extension CentralManager {
    func connectPeripheral(_ identifier: UUID, timeout nanoseconds: UInt64 = 10_000_000_000) async throws -> CBMPeripheral {
        try await asyncOperation { () -> CBMPeripheral in
            try await withCheckedThrowingContinuation { [weak self] continuation in
                guard let peripheral = self?.centralManager.retrievePeripherals(withIdentifiers: [identifier]).first else {
                    continuation.resume(throwing: CentralManager.Error.peripheralNotFound)
                    self?.logger.error("Peripheral not found")
                    return
                }

                self?.connectionContinuation = continuation
                self?.centralManager.connect(peripheral)
                self?.logger.log("Connecting to peripheral \(identifier)")
            }
        }
    }

    func readValue(for characteristic: CBMCharacteristic) async throws -> Data {
        try await asyncOperation { () -> Data in
            try await withCheckedThrowingContinuation { [weak self] continuation in
                guard case .some = self?.connectedPeripheral else {
                    continuation.resume(throwing: CentralManager.Error.peripheralNotFound)
                    return
                }

                let readValueContinuation = CharacteristicValueContinuation(continuation: continuation, characteristic: characteristic)
                self?.readValueContinuations.insert(readValueContinuation)
                self?.connectedPeripheral?.readValue(for: characteristic)
            }
        }
    }
}

extension CentralManager: CBMCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBMCentralManager) {
        print("centralManagerDidUpdateState")
    }

    func centralManager(_ central: CBMCentralManager, didConnect peripheral: CBMPeripheral) {
        logger.debug("didConnect peripheral \(peripheral.identifier.uuidString)")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        // Discover wifi service
        peripheral.discoverServices([Service.wifi])
    }

    func centralManager(_ central: CBMCentralManager, didDisconnectPeripheral peripheral: CBMPeripheral, error: Swift.Error?) {
        if let e = error {
            logger.error("didDisconnectPeripheral peripheral \(peripheral.identifier.uuidString) error: \(e)")
        } else {
            logger.debug("didDisconnectPeripheral peripheral \(peripheral.identifier.uuidString)")
        }
    }

    func centralManager(_ central: CBMCentralManager, didFailToConnect peripheral: CBMPeripheral, error: Swift.Error?) {
        logger.error("didFailToConnect peripheral \(peripheral.identifier.uuidString) error: \(error?.localizedDescription ?? "")")
        connectionContinuation?.resume(with: .failure(error ?? CentralManager.Error.peripheralNotFound))
    }
}

extension CentralManager: CBMPeripheralDelegate {
    func peripheral(_ peripheral: CBMPeripheral, didDiscoverServices error: Swift.Error?) {
        if let e = error {
            logger.error("didDiscoverServices error: \(e.localizedDescription)")
            connectionContinuation?.resume(throwing: e)
        } else {
            logger.debug("didDiscoverServices")
            guard let service = peripheral.services?.first(where: { $0.uuid == Service.wifi }) else {
                return
            }
            wifiService = service
            // Discover wifi characteristics
            peripheral.discoverCharacteristics([
                Service.Characteristic.version,
                Service.Characteristic.controlPoint,
                Service.Characteristic.dataOut
            ], for: peripheral.services!.first { $0.uuid == Service.wifi }!)
        }
    }

    func peripheral(_ peripheral: CBMPeripheral, didDiscoverCharacteristicsFor service: CBMService, error: Swift.Error?) {
        if let e = error {
            logger.error("didDiscoverCharacteristicsFor error: \(e.localizedDescription)")
            connectionContinuation?.resume(throwing: e)
        }
        guard let characteristics = service.characteristics else {
            return
        }

        for ch in characteristics {
            switch ch.uuid {
            case Service.Characteristic.version:
                logger.debug("found version characteristic")
                versionCharacteristic = ch
            case Service.Characteristic.controlPoint:
                logger.debug("found controlPoint characteristic")
                controlPointCharacteristic = ch
            case Service.Characteristic.dataOut:
                logger.debug("found dataOut characteristic")
                dataOutCharacteristic = ch
            default:
                break
            }
        }

        if versionCharacteristic != nil && controlPointCharacteristic != nil && dataOutCharacteristic != nil {
            connectionContinuation?.resume(with: .success(peripheral))
        }
    }

    func peripheral(_ peripheral: CBMPeripheral, didUpdateValueFor characteristic: CBMCharacteristic, error: Swift.Error?) {
        if let e = error {
            logger.error("didUpdateValueFor error: \(e.localizedDescription)")
        }
        logger.debug("didUpdateValueFor \(characteristic.uuid)")

        let handleData: (CBMCharacteristic, Swift.Error?, CharacteristicValueContinuation) -> Void = { characteristic, error, continuation in
            if let e = error {
                continuation.continuation.resume(throwing: e)
            } else if let data = characteristic.value {
                continuation.continuation.resume(with: .success(data))
            } else {
                continuation.continuation.resume(with: .failure(Error.noValue))
            }
        }

        if let continuation = readValueContinuations.first(where: { $0.characteristic == characteristic }) {
            handleData(characteristic, error, continuation)
            readValueContinuations.remove(continuation)
        } else if let continuation = identifiableContinuations.first(where: { $0.characteristic == characteristic }) {
            handleData(characteristic, error, continuation)
            identifiableContinuations.remove(continuation)
        } else if let publisher = valueStreams[characteristic] {
            if let e = error {
                publisher.send(completion: .failure(e))
            } else {
                publisher.send(characteristic.value)
            }
        }
    }

    func peripheral(_ peripheral: CBMPeripheral, didWriteValueFor characteristic: CBMCharacteristic, error: Swift.Error?) {
        print("didWriteValueFor characteristic")
    }
}