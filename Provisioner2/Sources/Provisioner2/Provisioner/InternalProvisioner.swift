//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation
import CoreBluetoothMock

public enum ProvisionerError: Error {
    /// Provided device id is not valid
    case badIdentifier
    /// Peripheral with provided deviceId is not found
    case noPeripheralFound
    /// Device is not connected
    case notConnected(Error)
    /// Bluetooth is not available
    case bluetoothNotAvailable

    case unknown
}

class InternalProvisioner: Provisioner {
    let connectionQueue = OperationQueue()

    let deviceId: String
    
    let centralManager: CBCentralManager
    weak var connectionDelegate: ProvisionerConnectionDelegate?

    var peripheral: CBPeripheral?

    var versionCharacteristic: CBCharacteristic?
    var dataOutCharacteristic: CBCharacteristic?
    var controlPointCharacteristic: CBCharacteristic?
 
    let logger = Logger(
        subsystem: Bundle(for: InternalProvisioner.self).bundleIdentifier ?? "",
        category: "provisioner.internal-provisioner"
    )

    init(deviceId: String, centralManager: CBCentralManager = CBCentralManagerFactory.instance()) {
        self.centralManager = centralManager
        self.deviceId = deviceId
        
        self.centralManager.delegate = self
        self.connectionQueue.isSuspended = true
    }

    func connect() {
        connectionQueue.cancelAllOperations()
        connectionQueue.addOperation { [weak self] in 
            guard let self = self else { return }
            guard case .poweredOn = self.centralManager.state else {
                self.connectionDelegate?.deviceFailedToConnect(error: ProvisionerError.bluetoothNotAvailable)
                return
            }
            guard let peripheralId = UUID(uuidString: self.deviceId) else {
                self.connectionDelegate?.deviceFailedToConnect(error: ProvisionerError.badIdentifier)
                return
            }
            guard let peripheral = self.centralManager.retrievePeripherals(withIdentifiers: [peripheralId]).first else {
                self.connectionDelegate?.deviceFailedToConnect(error: ProvisionerError.noPeripheralFound)
                return
            }

            self.centralManager.connect(peripheral)
        }
    }
    
    func readVersion() {
        
    }
    
    func readWiFiStatus() {
        
    }
    
    func readProvisioningStatus() {
        
    }
}

extension InternalProvisioner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown, .resetting:
            break
        case .unsupported, .unauthorized, .poweredOff:
            connectionQueue.isSuspended = true
            connectionDelegate?.deviceFailedToConnect(error: ProvisionerError.bluetoothNotAvailable)
        case .poweredOn:
            connectionQueue.isSuspended = false
        }
    }

    func centralManager(_ central:   CBMCentralManager, didConnect peripheral: CBMPeripheral) {
        self.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([wifiServiceUUID])
    }

    func centralManager(_ central: CBMCentralManager, didFailToConnect peripheral: CBMPeripheral, error: Error?) {
        let e: Error = error ?? ProvisionerError.unknown
        connectionDelegate?.deviceFailedToConnect(error: ProvisionerError.notConnected(e))
    }

    func centralManager(_ central: CBMCentralManager, didDisconnectPeripheral peripheral: CBMPeripheral, error: Error?) {
        connectionDelegate?.deviceDisconnected(error: error)
    }
}

extension InternalProvisioner: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBMPeripheral, didDiscoverServices error: Error?) {
        guard let wifiService = peripheral.services?.first(where: { $0.uuid == wifiServiceUUID }) else { return }
        peripheral.discoverCharacteristics([versionCharacteristicUUID, controlPointCharacteristicUUID, dataOutCharacteristicUUID], for: wifiService)
    }

    func peripheral(_ peripheral: CBMPeripheral, didDiscoverCharacteristicsFor service: CBMService, error: Error?) {
        guard let versionCharacteristic = service.characteristics?.first(where: { $0.uuid == versionCharacteristicUUID }) else { return }
        guard let controlPointCharacteristic = service.characteristics?.first(where: { $0.uuid == controlPointCharacteristicUUID }) else { return }
        guard let dataOutCharacteristic = service.characteristics?.first(where: { $0.uuid == dataOutCharacteristicUUID }) else { return }

        self.versionCharacteristic = versionCharacteristic
        self.controlPointCharacteristic = controlPointCharacteristic
        self.dataOutCharacteristic = dataOutCharacteristic

        peripheral.setNotifyValue(true, for: dataOutCharacteristic)

        connectionDelegate?.deviceConnected()
    }
}
