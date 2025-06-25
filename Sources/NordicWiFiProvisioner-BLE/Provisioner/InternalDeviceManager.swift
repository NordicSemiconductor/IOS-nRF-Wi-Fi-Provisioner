/*
* Copyright (c) 2022, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import CoreBluetoothMock

/// Error that is thrown when the request to the device was sent, but the device is not connected
public struct DeviceNotConnectedError: Error { }

class InternalDeviceManager {
    let connectionQueue = OperationQueue()

    let deviceId: UUID
    
    let centralManager: CBCentralManager
    
    weak var connectionDelegate: ConnectionDelegate?
    weak var infoDelegate: InfoDelegate?
    weak var provisionerScanDelegate: WiFiScannerDelegate?
    weak var provisionerDelegate: ProvisionDelegate?

    unowned var provisioner: DeviceManager!

    private var connectionInfo: BluetoothConnectionInfo?
    private (set) var connectionState: DeviceManager.ConnectionState = .disconnected {
        didSet {
            connectionDelegate?.deviceManager(provisioner, changedConnectionState: connectionState)
        }
    }
 
    private var overrideWifiServiceId: UUID?
    private var overrideVersionCharacteristicId: UUID?
    private var overrideControlPointCharacteristicId: UUID?
    private var overrideDataOutCharacteristicId: UUID?

    private var wifiServiceId: UUID {
        return overrideWifiServiceId ?? ServiceID.wifi
    }

    private var versionCharacteristicId: UUID {
        return overrideVersionCharacteristicId ?? CharacteristicID.version
    }

    private var controlPointCharacteristicId: UUID {
        return overrideControlPointCharacteristicId ?? CharacteristicID.controlPoint
    }

    private var dataOutCharacteristicId: UUID {
        return overrideDataOutCharacteristicId ?? CharacteristicID.dataOut
    }

    let logger = Logger(
        subsystem: Bundle(for: InternalDeviceManager.self).bundleIdentifier ?? "",
        category: "provisioner.internal-provisioner"
    )

    init(deviceId: UUID,
         provisioner: DeviceManager,
         centralManager: CBCentralManager = CBMCentralManagerFactory.instance(forceMock: MockManager.forceMock)) {
        self.centralManager = centralManager
        self.deviceId = deviceId
        
        self.centralManager.delegate = self
        self.connectionQueue.isSuspended = true
        self.provisioner = provisioner
    }

    func connect(wifiServiceId: UUID? = nil,
                versionCharacteristicId: UUID? = nil,
                controlPointCharacteristicId: UUID? = nil,
                dataOutCharacteristicId: UUID? = nil) {

        self.overrideWifiServiceId = wifiServiceId
        self.overrideVersionCharacteristicId = versionCharacteristicId
        self.overrideControlPointCharacteristicId = controlPointCharacteristicId
        self.overrideDataOutCharacteristicId = dataOutCharacteristicId

        connectionQueue.cancelAllOperations()
        connectionQueue.addOperation { [weak self] in 
            guard let self = self else { return }
            guard case .poweredOn = self.centralManager.state else {
                self.connectionDelegate?.deviceManagerDidFailToConnect(self.provisioner, error: ProvisionerError.bluetoothNotAvailable)
                return
            }
            guard let peripheral = self.centralManager.retrievePeripherals(withIdentifiers: [self.deviceId]).first else {
                self.connectionDelegate?.deviceManagerDidFailToConnect(self.provisioner, error: ProvisionerError.noPeripheralFound)
                return
            }

            self.connectionState = .connecting
            self.centralManager.connect(peripheral)
        }
    }
    
    func disconnect() {
        connectionQueue.addOperation { [weak self] in 
            guard let self else { return }
            guard let peripheral = self.centralManager.retrievePeripherals(withIdentifiers: [self.deviceId]).first else {
                self.connectionDelegate?.deviceManagerDisconnectedDevice(self.provisioner, error: ProvisionerError.noPeripheralFound)
                return
            }
            
            self.connectionState = .disconnecting
            self.centralManager.cancelPeripheralConnection(peripheral)
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
        peripheral.discoverServices([wifiServiceId.cbm])
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

        guard let wifiService = peripheral.services?.first(where: { $0.uuid == wifiServiceId.cbm }) else {
            return
        }
        peripheral.discoverCharacteristics([
            versionCharacteristicId.cbm,
            controlPointCharacteristicId.cbm,
            dataOutCharacteristicId.cbm
        ], for: wifiService)
    }

    func peripheral(_ peripheral: CBMPeripheral, didDiscoverCharacteristicsFor service: CBMService, error: Error?) {
        guard let versionCharacteristic = service.characteristics?.first(where: { $0.uuid == versionCharacteristicId.cbm }) else { return }
        guard let controlPointCharacteristic = service.characteristics?.first(where: { $0.uuid == controlPointCharacteristicId.cbm }) else { return }
        guard let dataOutCharacteristic = service.characteristics?.first(where: { $0.uuid == dataOutCharacteristicId.cbm }) else { return }

        self.connectionInfo?.versionCharacteristic = versionCharacteristic
        self.connectionInfo?.controlPointCharacteristic = controlPointCharacteristic
        self.connectionInfo?.dataOutCharacteristic = dataOutCharacteristic
        
        self.connectionInfo?.setNotify()

        self.connectionState = .connected
        connectionDelegate?.deviceManagerConnectedDevice(provisioner)
    }
    
    func peripheral(_ peripheral: CBMPeripheral, didUpdateValueFor characteristic: CBMCharacteristic, error: Error?) {
        if characteristic.uuid == versionCharacteristicId.cbm {
            if let data = characteristic.value {
                parseVersionData(data: data)
            } else {
                infoDelegate?.versionReceived(.failure(.emptyData))
            }
        } else if characteristic.uuid == controlPointCharacteristicId.cbm {
            if let data = characteristic.value {
                parseControlPointResponse(data: data)
            } else {
                // TODO: Handle empty data
            }
        } else if characteristic.uuid == dataOutCharacteristicId.cbm {
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
        guard !result.wifi.bssid.isEmpty else { return }
        let rssi: Int? = result.hasRssi ? Int(result.rssi) : nil
        provisionerScanDelegate?.deviceManager(provisioner, discoveredAccessPoint: WifiInfo(proto: result.wifi), rssi: rssi)
    }
}
