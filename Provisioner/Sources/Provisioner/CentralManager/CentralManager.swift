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
    enum Characteristic {
        case version
        case controlPoint
        case dataOut
    }

    let centralManager: CBMCentralManager
    private let logger = Logger(
            subsystem: Bundle(for: Provisioner.self).bundleIdentifier ?? "",
            category: "provisioner-central-manager"
    )

    private var connectedPeripheral: CBMPeripheral?
    private var connectionContinuation: CheckedContinuation<CBMPeripheral, Swift.Error>?

    private var wifiService: CBMService!
    private var versionCharacteristic: CBMCharacteristic!
    private var controlPointCharacteristic: CBMCharacteristic!
    private var dataOutCharacteristic: CBMCharacteristic!

    private var readValueContinuation: CharacteristicValueContinuation?
    private var identifiableContinuation: CharacteristicValueContinuation?
    private var valueStreams = PassthroughSubject<Data, Swift.Error>()

    init(centralManager: CBMCentralManager = CBMCentralManagerFactory.instance()) {
        self.centralManager = centralManager
        centralManager.delegate = self
    }
}

extension CentralManager {
    func connectPeripheral(_ identifier: UUID) async throws -> CBMPeripheral {
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

    /// Reads the value of the characteristic.
    func readValue(for characteristic: Characteristic) async throws -> Data {
        let cbmCharacteristic = cbmCharacteristic(for: characteristic)
        guard let peripheral = connectedPeripheral else {
            throw CentralManager.Error.peripheralNotFound
        }

        return try await withTimeout(seconds: 5) { () -> Data in
            try await withCheckedThrowingContinuation { [weak self] continuation in
                self?.readValueContinuation = CharacteristicValueContinuation(continuation: continuation, characteristic: cbmCharacteristic)
                peripheral.readValue(for: cbmCharacteristic)
            }
        }
    }

    /// Writes data to the characteristic and waits for the response.
    func writeValue(_ data: Data, for characteristic: Characteristic) async throws -> Data {
        let cbmCharacteristic = cbmCharacteristic(for: characteristic)
        guard let peripheral = connectedPeripheral else {
            throw CentralManager.Error.peripheralNotFound
        }

        do {
            return try await withTimeout(seconds: 5) { () -> Data in
                try await withCheckedThrowingContinuation { [weak self] continuation in
                    self?.identifiableContinuation = CharacteristicValueContinuation(continuation: continuation, characteristic: cbmCharacteristic)
                    peripheral.writeValue(data, for: cbmCharacteristic, type: .withResponse)
                }
            }
        } catch let e {
            logger.error("Failed to write value to characteristic \(cbmCharacteristic.debugDescription): \(e.localizedDescription)")
            throw e
        }
    }

    func notifications(for characteristic: Characteristic) -> AnyPublisher<Data, Swift.Error> {
        return valueStreams
                .eraseToAnyPublisher()
    }
}

// MARK: - Private methods
extension CentralManager {
    // Convert Characteristic to CBMCharacteristic
    private func cbmCharacteristic(for characteristic: Characteristic) -> CBMCharacteristic {
        switch characteristic {
        case .version:
            return versionCharacteristic
        case .controlPoint:
            return controlPointCharacteristic
        case .dataOut:
            return dataOutCharacteristic
        }
    }
}

// MARK: - CBMPeripheralDelegate
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
            logger.error("didDisconnectPeripheral peripheral \(peripheral.identifier.uuidString) error: \(e.localizedDescription)")
        } else {
            logger.debug("didDisconnectPeripheral peripheral \(peripheral.identifier.uuidString)")
        }
    }

    func centralManager(_ central: CBMCentralManager, didFailToConnect peripheral: CBMPeripheral, error: Swift.Error?) {
        logger.error("didFailToConnect peripheral \(peripheral.identifier.uuidString) error: \(error?.localizedDescription ?? "")")
        connectionContinuation?.resume(with: .failure(error ?? CentralManager.Error.peripheralNotFound))
    }
}

// MARK: - CBMPeripheralDelegate
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
                peripheral.setNotifyValue(true, for: controlPointCharacteristic)
            case Service.Characteristic.dataOut:
                logger.debug("found dataOut characteristic")
                dataOutCharacteristic = ch
                peripheral.setNotifyValue(true, for: dataOutCharacteristic)
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

        if let c = identifiableContinuation, c.characteristic == characteristic {
            handleData(characteristic, error, c)
            identifiableContinuation = nil // reset
        } else if let c = readValueContinuation, c.characteristic == characteristic {
            handleData(characteristic, error, c)
            readValueContinuation = nil // reset
        } else if characteristic.uuid == Service.Characteristic.dataOut {
            if let data = characteristic.value {
                valueStreams.send(data)
            } else if let e = error {
                valueStreams.send(completion: .failure(e))
            }
        }
    }

    func peripheral(_ peripheral: CBMPeripheral, didWriteValueFor characteristic: CBMCharacteristic, error: Swift.Error?) {
        print("didWriteValueFor characteristic")
    }
}
