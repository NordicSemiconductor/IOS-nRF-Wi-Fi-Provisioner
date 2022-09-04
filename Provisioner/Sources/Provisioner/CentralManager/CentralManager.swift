//
// Created by Nick Kibysh on 02/08/2022.
//

import Foundation
import CoreBluetoothMock
import Combine
import os


private struct Service {
    static let wifi = CBMUUID(string: "14387800-130c-49e7-b877-2881c89cb258")

    struct Characteristic {
        static let version = CBMUUID(string: "14387801-130c-49e7-b877-2881c89cb258")
        static let controlPoint = CBMUUID(string: "14387802-130c-49e7-b877-2881c89cb258")
        static let dataOut = CBMUUID(string: "14387803-130c-49e7-b877-2881c89cb258")
    }
}

private struct WifiDevice {
    var peripheral: CBPeripheral
    var wifi: CBService!
    var version: CBCharacteristic!
    var controlPoint: CBCharacteristic!
    var dataOut: CBCharacteristic!

    func valid() throws -> Bool {
        if wifi != nil && version != nil && controlPoint != nil && dataOut != nil {
            return true
        } else {
            if wifi == nil {
                throw BluetoothConnectionError.wifiServiceNotFound
            } else if version == nil {
                throw BluetoothConnectionError.versionCharacteristicNotFound
            } else if controlPoint == nil {
                throw BluetoothConnectionError.controlCharacteristicPointNotFound
            } else if dataOut == nil {
                throw BluetoothConnectionError.dataOutCharacteristicNotFound
            } else {
                throw BluetoothConnectionError.unknownError
            }
        }
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

extension CentralManager {
    enum Error: Swift.Error {
        case peripheralNotFound
        case timeout
        case noValue
    }
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

    // State of the connection
    let connectionStateSubject = PassthroughSubject<Provisioner.BluetoothConnectionStatus, Never>()

    private var readValueContinuation: CharacteristicValueContinuation?
    private var identifiableContinuation: CharacteristicValueContinuation?

    private var connectionExecutor = AsyncExecutor<WifiDevice>()

    private var valueStreams = PassthroughSubject<Data, Swift.Error>()
    private var connectedDevice: WifiDevice!

    init(centralManager: CBMCentralManager = CBMCentralManagerFactory.instance()) {
        self.centralManager = centralManager
        centralManager.delegate = self
        connectionStateSubject.send(.disconnected)
    }
}

extension CentralManager {
    func connectPeripheral(_ identifier: UUID) async throws -> CBPeripheral {
        connectionStateSubject.send(.connecting)
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [identifier]).first else {
            connectionStateSubject.send(.connectionCanceled(.error(Error.peripheralNotFound)))
            throw BluetoothConnectionError.canNotConnect
        }

        centralManager.connect(peripheral, options: nil)

        do {
            self.connectedDevice = try await withTimeout(seconds: 20) {
                try await self.connectionExecutor.execute()
            }
        } catch let e {
            connectionStateSubject.send(.connectionCanceled(.error(TimeoutError())))
            throw e
        }

        connectionExecutor.reset()

        connectedDevice.peripheral.delegate = self
        connectedDevice.peripheral.discoverServices([Service.wifi])

        do {
            self.connectedDevice = try await withTimeout(seconds: 30) {
                try await self.connectionExecutor.execute()
            }
        } catch let e {
            connectionStateSubject.send(.connectionCanceled(.error(TimeoutError())))
            throw e
        }

        connectionStateSubject.send(.connected)

        return connectedDevice.peripheral
    }

    /// Reads the value of the characteristic.
    func readValue(for characteristic: Characteristic) async throws -> Data {
        let cbmCharacteristic = cbmCharacteristic(for: characteristic)
        let peripheral = connectedDevice.peripheral

        return try await withTimeout(seconds: 30) { () -> Data in
            try await withCheckedThrowingContinuation { [weak self] continuation in
                self?.readValueContinuation = CharacteristicValueContinuation(continuation: continuation, characteristic: cbmCharacteristic)
                peripheral.readValue(for: cbmCharacteristic)
            }
        }
    }

    /// Writes data to the characteristic and waits for the response.
    func writeValue(_ data: Data, for characteristic: Characteristic) async throws -> Data {
        let cbmCharacteristic = cbmCharacteristic(for: characteristic)
        let peripheral = connectedDevice.peripheral

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
            return connectedDevice.version
        case .controlPoint:
            return connectedDevice.controlPoint
        case .dataOut:
            return connectedDevice.dataOut
        }
    }
}

// MARK: - CBMPeripheralDelegate
extension CentralManager: CBMCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBMCentralManager) {
        logger.debug("Central manager did update state: \(central.state)")
    }

    func centralManager(_ central: CBMCentralManager, didConnect peripheral: CBMPeripheral) {
        logger.debug("didConnect peripheral \(peripheral.identifier.uuidString)")
        connectionExecutor.complete(with: WifiDevice(peripheral: peripheral))
    }

    func centralManager(_ central: CBMCentralManager, didDisconnectPeripheral peripheral: CBMPeripheral, error: Swift.Error?) {
        if let e = error {
            logger.error("didDisconnectPeripheral peripheral \(peripheral.identifier.uuidString) error: \(e.localizedDescription)")
            connectionStateSubject.send(.connectionCanceled(.error(e)))
        } else {
            logger.debug("didDisconnectPeripheral peripheral \(peripheral.identifier.uuidString)")
            connectionStateSubject.send(.connectionCanceled(.byRequest))
        }
    }

    func centralManager(_ central: CBMCentralManager, didFailToConnect peripheral: CBMPeripheral, error: Swift.Error?) {
        logger.error("didFailToConnect peripheral \(peripheral.identifier.uuidString) error: \(error?.localizedDescription ?? "")")
        connectionExecutor.complete(with: error ?? BluetoothConnectionError.unknownError)
    }
}

// MARK: - CBMPeripheralDelegate
extension CentralManager: CBMPeripheralDelegate {
    func peripheral(_ peripheral: CBMPeripheral, didDiscoverServices error: Swift.Error?) {
        if let e = error {
            logger.error("didDiscoverServices error: \(e.localizedDescription)")
            connectionExecutor.complete(with: e)
        } else {
            logger.debug("didDiscoverServices")
            guard let service = peripheral.services?.first(where: { $0.uuid == Service.wifi }) else {
                return
            }
            connectedDevice.wifi = service
            // Discover wifi characteristics
            peripheral.discoverCharacteristics([
                Service.Characteristic.version,
                Service.Characteristic.controlPoint,
                Service.Characteristic.dataOut
            ], for: service)
        }
    }

    func peripheral(_ peripheral: CBMPeripheral, didDiscoverCharacteristicsFor service: CBMService, error: Swift.Error?) {
        if let e = error {
            logger.error("didDiscoverCharacteristicsFor error: \(e.localizedDescription)")
            connectionExecutor.complete(with: e)
        }
        guard let characteristics = service.characteristics else {
            return
        }

        for ch in characteristics {
            switch ch.uuid {
            case Service.Characteristic.version:
                logger.debug("found version characteristic")
                connectedDevice.version = ch
                peripheral.setNotifyValue(true, for: ch)
            case Service.Characteristic.controlPoint:
                logger.debug("found controlPoint characteristic")
                connectedDevice.controlPoint = ch
                peripheral.setNotifyValue(true, for: ch)
            case Service.Characteristic.dataOut:
                logger.debug("found dataOut characteristic")
                connectedDevice.dataOut = ch
                peripheral.setNotifyValue(true, for: ch)
            default:
                break
            }
        }

        if (try? connectedDevice.valid()) == true {
            connectionExecutor.complete(with: connectedDevice)
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