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
    
    case notSupported

    case unknown
    /// Data was received but unnable to parse
    case badData
    /// Device failure response
    case deviceFailureResponse
    /// Response is successful but it's empty
    case emptyResponse
}

/// Error that is thrown when the request to the device was sent, but the device is not connected
public struct DeviceNotConnectedError: Error { }

class InternalProvisioner {
    let connectionQueue = OperationQueue()

    let deviceId: String
    
    let centralManager: CBCentralManager
    weak var connectionDelegate: ProvisionerConnectionDelegate?
    weak var infoDelegate: ProvisionerInfoDelegate?
    weak var provisionerScanDelegate: ProvisionerScanDelegate?

    private var connectionInfo: BluetoothConnectionInfo?
    private (set) var connectionState: Provisioner.ConnectionState = .disconnected {
        didSet {
            connectionDelegate?.connectionStateChanged(connectionState)
        }
    }
 
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

            self.connectionState = .connecting
            self.centralManager.connect(peripheral)
        }
    }
    
    func readVersion() throws {
        guard connectionInfo?.isReady == true else {
            throw DeviceNotConnectedError()
        }
        
        connectionInfo?.readVersion()
    }
    
    func readDeviceStatus() throws {
        guard connectionInfo?.isReady == true else {
            throw DeviceNotConnectedError()
        }
        
        try sendRequest(opCode: .getStatus)
    }
    
    func startScan(scanParams: ScanParams) throws {
        guard connectionInfo?.isReady == true else {
            throw DeviceNotConnectedError()
        }
        
        try sendRequest(opCode: .startScan, scanParam: scanParams.proto)
    }
    
    func stopScan() throws {
        guard connectionInfo?.isReady == true else {
            throw DeviceNotConnectedError()
        }
        
        try sendRequest(opCode: .stopScan)
    }
}

// MARK: - Private Methods
extension InternalProvisioner {
    private func sendRequest(opCode: Proto.OpCode, config: Proto.WifiConfig? = nil, scanParam: Proto.ScanParams? = nil) throws {
        var request = Proto.Request()
        request.opCode = opCode
        if let conf = config {
            request.config = conf
        }
        
        if let scanParam {
            request.scanParams = scanParam
        }
        
        let data = try request.serializedData()
        connectionInfo.map { ci in
            ci.peripheral.writeValue(data, for: ci.controlPointCharacteristic, type: .withResponse)
        }
    }
}

// MARK: - CBCentralManagerDelegate
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
        self.connectionInfo = BluetoothConnectionInfo(peripheral: peripheral)
        peripheral.delegate = self
        peripheral.discoverServices([wifiServiceUUID])
    }

    func centralManager(_ central: CBMCentralManager, didFailToConnect peripheral: CBMPeripheral, error: Error?) {
        let e: Error = error ?? ProvisionerError.unknown
        connectionDelegate?.deviceFailedToConnect(error: ProvisionerError.notConnected(e))
        self.connectionState = .disconnected
    }

    func centralManager(_ central: CBMCentralManager, didDisconnectPeripheral peripheral: CBMPeripheral, error: Error?) {
        connectionDelegate?.deviceDisconnected(error: error)
        self.connectionState = .disconnected
    }
}

// MARK: - CBPeripheralDelegate
extension InternalProvisioner: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBMPeripheral, didDiscoverServices error: Error?) {
        guard case .none = error else {
            connectionDelegate?.deviceFailedToConnect(error: ProvisionerError.notSupported)
            centralManager.cancelPeripheralConnection(peripheral)
            self.connectionState = .disconnecting
            return
        }

        guard let wifiService = peripheral.services?.first(where: { $0.uuid == wifiServiceUUID }) else {
            return
        }
        peripheral.discoverCharacteristics([versionCharacteristicUUID, controlPointCharacteristicUUID, dataOutCharacteristicUUID], for: wifiService)
    }

    func peripheral(_ peripheral: CBMPeripheral, didDiscoverCharacteristicsFor service: CBMService, error: Error?) {
        guard let versionCharacteristic = service.characteristics?.first(where: { $0.uuid == versionCharacteristicUUID }) else { return }
        guard let controlPointCharacteristic = service.characteristics?.first(where: { $0.uuid == controlPointCharacteristicUUID }) else { return }
        guard let dataOutCharacteristic = service.characteristics?.first(where: { $0.uuid == dataOutCharacteristicUUID }) else { return }
        
        self.connectionInfo?.versionCharacteristic = versionCharacteristic
        self.connectionInfo?.controlPointCharacteristic = controlPointCharacteristic
        self.connectionInfo?.dataOutCharacteristic = dataOutCharacteristic
        
        self.connectionInfo?.setNotify()

        self.connectionState = .connected
        connectionDelegate?.deviceConnected()
    }
    
    func peripheral(_ peripheral: CBMPeripheral, didUpdateValueFor characteristic: CBMCharacteristic, error: Error?) {
        if characteristic.uuid == connectionInfo?.versionCharacteristic.uuid {
            if let data = characteristic.value {
                parseVersionData(data: data)
            } else {
                infoDelegate?.versionReceived(.failure(.emptyData))
            }
        } else if characteristic.uuid == connectionInfo?.controlPointCharacteristic.uuid {
            if let data = characteristic.value {
                parseControlPointResponse(data: data)
            } else {
                infoDelegate?.versionReceived(.failure(.emptyData))
            }
        } else if characteristic.uuid == connectionInfo?.dataOutCharacteristic.uuid {
            if let data = characteristic.value {
                parseDataOutResult(data: data)
            } else {
                infoDelegate?.versionReceived(.failure(.emptyData))
            }
        }
    }
}

// MARK: - Parsing methods
extension InternalProvisioner {
    func parseVersionData(data: Data) {
        do {
            let info = try Proto.Info(serializedData: data)
            infoDelegate?.versionReceived(.success(Int(info.version)))
        } catch {
            infoDelegate?.versionReceived(.failure(.badData))
        }
    }
    
    func parseControlPointResponse(data: Data) {
        do {
            let response = try Proto.Response(serializedData: data)
            parseResponse(response)
        } catch {
            infoDelegate?.deviceStatusReceived(.failure(.badData))
        }
    }
    
    func parseDataOutResult(data: Data) {
        do {
            let result = try Proto.Result(serializedData: data)
            if result.hasScanRecord {
                handleScanRecord(result.scanRecord)
            } else if result.hasState {

            } else if result.hasReason {

            }
        } catch {
            // TODO: Handle error
        }
        
    }
    
    func parseResponse(_ response: Proto.Response) {
        switch response.requestOpCode {
        case .reserved:
            return 
        case .getStatus:
            parseGetStatus(response)
        case .startScan:
            parseStartScan(response)
        case .stopScan:
            // TODO: Handle Stop Scan
            break
        default:
            fatalError("Not implemented")
        }
    }

    // MARK: Parse by OpCode
    func parseGetStatus(_ response: Proto.Response) {
        switch response.status {
        case .success:
            guard response.hasDeviceStatus else {
                // TODO: Unit Test
                infoDelegate?.deviceStatusReceived(.failure(.emptyResponse))
                return
            }
            
            infoDelegate?.deviceStatusReceived(.success(DeviceStatus(proto: response.deviceStatus)))
        default:
            infoDelegate?.deviceStatusReceived(.failure(.deviceFailureResponse))
        }
    }
    
    func parseStartScan(_ response: Proto.Response) {
        switch response.status {
        case .success:
            // TODO: Handle response
            break
        default:
            // TODO: Handle response
            break
        }
    }

    // MARK: Handle Result
    func handleScanRecord(_ result: Proto.ScanRecord) {
        guard result.hasWifi else { return }
        let rssi: Int? = result.hasRssi ? Int(result.rssi) : nil
        provisionerScanDelegate?.accessPointDiscovered(WifiInfo(proto: result.wifi), rssi: rssi)
    }
}
