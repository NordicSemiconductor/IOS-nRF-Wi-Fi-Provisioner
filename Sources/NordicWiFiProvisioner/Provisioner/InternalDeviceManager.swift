//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation
import CoreBluetoothMock

/// Error that is thrown when the request to the device was sent, but the device is not connected
public struct DeviceNotConnectedError: Error { }

class InternalDeviceManager {
    let connectionQueue = OperationQueue()

    let deviceId: String
    
    let centralManager: CBCentralManager
    weak var connectionDelegate: ConnectionDelegate?
    weak var infoDelegate: InfoDelegate?
    weak var provisionerScanDelegate: WiFiScanerDelegate?
    weak var provisionerDelegate: ProvisionDelegate?

    unowned var provisioner: DeviceManager!

    private var connectionInfo: BluetoothConnectionInfo?
    private (set) var connectionState: DeviceManager.ConnectionState = .disconnected {
        didSet {
            connectionDelegate?.deviceManager(provisioner, changedConnectionState: connectionState)
        }
    }
 
    let logger = Logger(
        subsystem: Bundle(for: InternalDeviceManager.self).bundleIdentifier ?? "",
        category: "provisioner.internal-provisioner"
    )

    init(deviceId: String, provisioner: DeviceManager, centralManager: CBCentralManager = CBCentralManagerFactory.instance()) {
        self.centralManager = centralManager
        self.deviceId = deviceId
        
        self.centralManager.delegate = self
        self.connectionQueue.isSuspended = true
        self.provisioner = provisioner
    }

    func connect() {
        connectionQueue.cancelAllOperations()
        connectionQueue.addOperation { [weak self] in 
            guard let self = self else { return }
            guard case .poweredOn = self.centralManager.state else {
                self.connectionDelegate?.deviceManagerDidFailToConnect(self.provisioner, error: ProvisionerError.bluetoothNotAvailable)
                return
            }
            guard let peripheralId = UUID(uuidString: self.deviceId) else {
                self.connectionDelegate?.deviceManagerDidFailToConnect(self.provisioner, error: ProvisionerError.badIdentifier)
                return
            }
            guard let peripheral = self.centralManager.retrievePeripherals(withIdentifiers: [peripheralId]).first else {
                self.connectionDelegate?.deviceManagerDidFailToConnect(self.provisioner, error: ProvisionerError.noPeripheralFound)
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
    
    func setConfig(_ config: WifiConfig) throws {
        guard connectionInfo?.isReady == true else {
            throw DeviceNotConnectedError()
        }
        
        try sendRequest(opCode: .setConfig, config: config.proto)
    }
    
    func forgetConfig() throws {
        guard connectionInfo?.isReady == true else {
            throw DeviceNotConnectedError()
        }
        
        try sendRequest(opCode: .forgetConfig)
    }
}

// MARK: - Private Methods
extension InternalDeviceManager {
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
extension InternalDeviceManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown, .resetting:
            break
        case .unsupported, .unauthorized, .poweredOff:
            connectionQueue.isSuspended = true
            connectionDelegate?.deviceManagerDidFailToConnect(provisioner, error: ProvisionerError.bluetoothNotAvailable)
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
        connectionDelegate?.deviceManagerDidFailToConnect(provisioner, error: ProvisionerError.notConnected(e))
        self.connectionState = .disconnected
    }

    func centralManager(_ central: CBMCentralManager, didDisconnectPeripheral peripheral: CBMPeripheral, error: Error?) {
        connectionDelegate?.deviceManagerDisconnectedDevice(provisioner, error: error)
        self.connectionState = .disconnected
    }
}

// MARK: - CBPeripheralDelegate
extension InternalDeviceManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBMPeripheral, didDiscoverServices error: Error?) {
        guard case .none = error else {
            connectionDelegate?.deviceManagerDidFailToConnect(provisioner, error: ProvisionerError.notSupported)
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
        connectionDelegate?.deviceManagerConnectedDevice(provisioner)
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
                // TODO: Handle empty data
            }
        } else if characteristic.uuid == connectionInfo?.dataOutCharacteristic.uuid {
            if let data = characteristic.value {
                parseDataOutResult(data: data)
            } else {
                // TODO: Handle empty data
            }
        }
    }
}

// MARK: - Parsing methods
extension InternalDeviceManager {
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
            // TODO: Handle bad data
        }
    }
    
    func parseDataOutResult(data: Data) {
        do {
            let result = try Proto.Result(serializedData: data)
            if result.hasScanRecord {
                handleScanRecord(result.scanRecord)
            } else if result.hasReason {
                provisionerDelegate?.deviceManager(provisioner, didChangeState: .connectionFailed(ConnectionFailureReason(proto: result.reason)))
            } else if result.hasState {
                provisionerDelegate?.deviceManager(provisioner, didChangeState: ConnectionState(proto: result.state))
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
            parseStopScan(response)
        case .setConfig:
            parseSetConfig(response)
        case .forgetConfig:
            parseForgetConfig(response)
        }
    }

    // MARK: Parse by OpCode
    func parseGetStatus(_ response: Proto.Response) {
        switch response.status {
        case .success:
            guard response.hasDeviceStatus else {
                infoDelegate?.deviceStatusReceived(.failure(.emptyResponse))
                return
            }
            
            infoDelegate?.deviceStatusReceived(.success(DeviceStatus(proto: response.deviceStatus)))
        default:
            infoDelegate?.deviceStatusReceived(.failure(convertResponseError(response)))
        }
    }
    
    func parseStartScan(_ response: Proto.Response) {
        switch response.status {
        case .success:
            provisionerScanDelegate?.deviceManagerDidStartScan(provisioner, error: nil)
        default:
            provisionerScanDelegate?.deviceManagerDidStartScan(provisioner, error: convertResponseError(response))
        }
    }

    func parseStopScan(_ response: Proto.Response) {
        switch response.status {
        case .success:
            provisionerScanDelegate?.deviceManagerDidStopScan(provisioner, error: nil)
        default:
            provisionerScanDelegate?.deviceManagerDidStopScan(provisioner, error: convertResponseError(response))
        }
    }

    func parseSetConfig(_ response: Proto.Response) {
        switch response.status {
        case .success:
            provisionerDelegate?.deviceManagerDidSetConfig(provisioner, error: nil)
        default:
            provisionerDelegate?.deviceManagerDidSetConfig(provisioner, error: convertResponseError(response))
        }
    }
    
    func parseForgetConfig(_ response: Proto.Response) {
        switch response.status {
        case .success:
            provisionerDelegate?.deviceManagerDidForgetConfig(provisioner, error: nil)
        default:
            provisionerDelegate?.deviceManagerDidForgetConfig(provisioner, error: convertResponseError(response))
        }
    }

    func convertResponseError(_ response: Proto.Response) -> ProvisionerError {
        switch response.status {
        case .success:
            fatalError("Success response should never be passed here")
        case .invalidArgument:
            return ProvisionerError.invalidArgument
        case .invalidProto:
            return ProvisionerError.failedToDecodeRequest
        case .internalError:
            return ProvisionerError.internalError
        }
    }

    // MARK: Handle Result
    func handleScanRecord(_ result: Proto.ScanRecord) {
        guard result.hasWifi else { return }
        let rssi: Int? = result.hasRssi ? Int(result.rssi) : nil
        provisionerScanDelegate?.deviceManager(provisioner, discoveredAccessPoint: WifiInfo(proto: result.wifi), rssi: rssi)
    }
}
