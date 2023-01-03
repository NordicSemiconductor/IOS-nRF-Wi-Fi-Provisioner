//
//  File.swift
//  
//
//  Created by Nick Kibysh on 16/12/2022.
//

import Foundation
import CoreBluetoothMock

private extension CBMCharacteristicMock {
    static let version = CBMCharacteristicMock(type: CharacteristicID.version.cbm, properties: [.read])
    static let controlPoint = CBMCharacteristicMock(type: CharacteristicID.controlPoint.cbm, properties: [.write, .notify])
    static let dataOut = CBMCharacteristicMock(type: CharacteristicID.dataOut.cbm, properties: [.notify])
}

private extension DeviceStatus {
    static let notProvisioned = DeviceStatus(state: .disconnected, provisioningInfo: nil)
    static let provisionedNotConnected = DeviceStatus(state: .disconnected, provisioningInfo: WiFiScanResultFaker().allNetworks[0].0)
    static let provisionedConnected = DeviceStatus(state: .connected, provisioningInfo: WiFiScanResultFaker().allNetworks[20].0)
}

private extension ConnectionState {
    static var successStates: [ConnectionState] = [
        .authentication, .association, .obtainingIp, .connected
    ]
}

private func msleep(_ nanosec: TimeInterval) {
    usleep(UInt32(nanosec * 1_000_000))
}

/// Delegate that provides result of the provisioning process.
public protocol MockProvisionDelegate {
    /// Returns result of the provisioning process.
    func provisionResult(wifiConfig: WifiConfig) -> Result<ConnectionInfo, ConnectionFailureReason>
}

class DefaultMockProvisionDelegate: MockProvisionDelegate {
    func provisionResult(wifiConfig: WifiConfig) -> Result<ConnectionInfo, ConnectionFailureReason> {
        if wifiConfig.wifi?.auth == .open || wifiConfig.passphrase == "Password1" {
            return .success(ConnectionInfo(ip: IPAddress(data: Data([192,168,0,1]))))
        } else {
            return .failure(.authError)
        }
    }
}

extension MockDevice {
    static let notProvisioned = MockDevice(
        id: "14387800-130c-49e7-b877-2881c89cb260",
        name: "nRF-7 Wi-Fi (1)",
        deviceStatus: DeviceStatus.notProvisioned,
        version: 1
    )
    
    static let provisionedNotConnected = MockDevice(
        id: "14387800-130c-49e7-b877-2881c89cb261",
        name: "nRF-7 Wi-Fi (2)",
        deviceStatus: DeviceStatus.provisionedNotConnected,
        version: 2
    )
    
    static let provisionedConnected = MockDevice(
        id: "14387800-130c-49e7-b877-2881c89cb262",
        name: "nRF-7 Wi-Fi (3)",
        deviceStatus: DeviceStatus.provisionedConnected,
        version: 3
    )
}

/// Mock device emulates nRF-7 device.
open class MockDevice {
    /// Identifier of the device. Must be UUID string.
    let id: String
    /// Name of the device.
    let name: String
    /// Device status. Contains information about the device state and provisioning info streight after the connection.
    let deviceStatus: DeviceStatus
    lazy var provisioned: Bool = deviceStatus.provisioningInfo != nil
    lazy var connected: Bool = deviceStatus.state == .connected
    let version: UInt
    let bluetoothRSSI: Int
    let wifiRSSI: Int?
    
    
    let queue: DispatchQueue
    
    /// Advertising interval, in seconds.
    var interval: TimeInterval = 1.0
    /// Time interval between request and response
    var requestTimeInterval: TimeInterval = 0.2
    /// Time Interval between discovered Wi-Fi scan results
    var scanTimeInterval: TimeInterval = 0.3
    /// Time Interval between changing of the connection state
    var connectionTimeInterval: TimeInterval = 0.9
    
    var provisionDelegate: MockProvisionDelegate = DefaultMockProvisionDelegate()
    var searchResultProvider: MockScanResultProvider = WiFiScanResultFaker()
    
    /**
        Creates new instance of the MockDevice.
        
        - parameter id: Identifier of the device. Must be UUID string.
        - parameter name: Name of the device.
        - parameter deviceStatus: Device status. Contains information about the device state and provisioning info streight after the connection.
        - parameter version: Version of the device firmware.
        - parameter bluetoothRSSI: Bluetooth RSSI of the device. Default value is -50.
        - parameter wifiRSSI: RSSI of the Wi-Fi network to which the device is connected. Default value is -55.
        - parameter queue: Queue on which the delegate methods will be called.
        - parameter provisionDelegate: Delegate that provides result of the provisioning process.
        - parameter searchResultProvider: Provider of the Wi-Fi scan results. Default value is ``WiFiScanResultFaker``.
    */
    public init(
        id: String = UUID().uuidString,
        name: String,
        deviceStatus: DeviceStatus = DeviceStatus(),
        version: UInt,
        bluetoothRSSI: Int = -50,
        wifiRSSI: Int? = -55,
        queue: DispatchQueue = .main,
        provisionDelegate: MockProvisionDelegate? = nil,
        searchResultProvider: MockScanResultProvider = WiFiScanResultFaker()
    ) {
        self.id = id
        self.name = name
        self.deviceStatus = deviceStatus
        self.version = version
        self.bluetoothRSSI = bluetoothRSSI
        self.wifiRSSI = wifiRSSI
        self.queue = queue
        self.provisionDelegate = provisionDelegate ?? DefaultMockProvisionDelegate()
        self.searchResultProvider = searchResultProvider
    }
    
    // MARK: - Initial Values
    private var lastWiFiConfig: WifiConfig?
    
    private var connectionInfo: ConnectionInfo? = nil
    
    private var timer: Timer!
    
    private (set) lazy var spec: CoreBluetoothMock.CBMPeripheralSpec = CBMPeripheralSpec
        .simulatePeripheral(
            identifier: UUID(uuidString: id)!,
            proximity: .near
        )
        .advertising(
            advertisementData: [
                CBMAdvertisementDataLocalNameKey    : name,
                CBMAdvertisementDataServiceUUIDsKey : [ServiceID.wifi.cbm],
                CBMAdvertisementDataIsConnectable   : true as NSNumber,
                CBMAdvertisementDataServiceDataKey   : [
                    ServiceID.wifi.cbm : Data([
                        UInt8(version), // Version
                        0x00, // Reserved
                        UInt8(provisioned ? 0x01 : 0x00) | (connected ? 0x02 : 0x00), // Flags
                        UInt8(bitPattern: Int8(bluetoothRSSI))  // Wi-Fi RSSI
                    ])
                ]
            ],
            withInterval: interval,
            alsoWhenConnected: false
        )
        .connectable(
            name: name,
            services: [
                CBMServiceMock(
                    type: ServiceID.wifi.cbm,
                    primary: true,
                    characteristics: [
                        .version,
                        .controlPoint,
                        .dataOut
                    ])
            ],
            delegate: self,
            connectionInterval: 0.150,
            mtu: 23)
        .allowForRetrieval()
        .build()
}

extension MockDevice {
    // MARK: - Data Methods
    func parseWriteData(_ data: Data, peripheral: CBMPeripheralSpec) {
        do {
            let request = try Proto.Request(serializedData: data)
            parseRequest(request, peripheral: peripheral)
        } catch {
            fatalError()
        }
    }
    
    func parseRequest(_ request: Proto.Request, peripheral: CBMPeripheralSpec) {
        switch request.opCode {
        case .reserved:
            break
        case .getStatus:
            getStatus(peripheral)
        case .startScan:
            startScan(peripheral)
        case .stopScan:
            stopScan(peripheral)
        case .setConfig:
            setConfig(peripheral, request: request)
        case .forgetConfig:
            forgetConfig(peripheral)
        }
    }
    
    func getStatus(_ peripheral: CBMPeripheralSpec) {
        if let config = lastWiFiConfig {
            let deviceStatus: DeviceStatus
            switch provisionDelegate.provisionResult(wifiConfig: config) {
            case .success(let connection):
                deviceStatus = DeviceStatus(state: .connected, provisioningInfo: config.wifi, connectionInfo: connection)
                peripheral.simulateValueUpdate(try! deviceStatus.proto.serializedData(), for: .controlPoint)
            case .failure(let reason):
                deviceStatus = DeviceStatus(state: .connectionFailed(reason), provisioningInfo: config.wifi)
                peripheral.simulateValueUpdate(try! deviceStatus.proto.serializedData(), for: .controlPoint)
            }
            self.sendResponse(peripheral, deviceStatus: deviceStatus.proto, requestCode: .getStatus)
        } else {
            self.sendResponse(peripheral, deviceStatus: deviceStatus.proto, requestCode: .getStatus)
        }
    }
    
    func startScan(_ peripheral: CBMPeripheralSpec) {
        self.sendResponse(peripheral, requestCode: .startScan) { [weak self] in
            guard let self else { return }
            
            let allResults = self.searchResultProvider.allNetworks.shuffled()
            var scanResultIterator = allResults.makeIterator()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { t in
                guard let scanResult = scanResultIterator.next() else {
                    t.invalidate()
                    return
                }
                var scanRecord = Proto.ScanRecord()
                scanRecord.wifi = scanResult.0.proto
                scanRecord.rssi = Int32(scanResult.1)
                
                let result = self.result(scanRecord: scanRecord)
                peripheral.simulateValueUpdate(result, for: .dataOut)
            })
        }
    }
    
    func stopScan(_ peripheral: CBMPeripheralSpec) {
        self.sendResponse(peripheral, requestCode: .stopScan) { [weak self] in
            self?.timer.invalidate()
        }
    }
    
    func setConfig(_ peripheral: CBMPeripheralSpec, request: Proto.Request) {
        let states: [ConnectionState] = [.authentication, .association, .obtainingIp, .connected]
        
        self.sendResponse(peripheral, requestCode: .setConfig) { [weak self] in
            guard let self else { return }
            
            let conf = WifiConfig(proto: request.config)
            self.lastWiFiConfig = conf
            
            msleep(self.scanTimeInterval)
            
            switch self.provisionDelegate.provisionResult(wifiConfig: conf) {
            case .success(_):
                self.sendConnectionStates(peripheral, connectionStatuses: states)
            case .failure(let reason):
                self.sendFailReason(peripheral, reason: reason)
            }
        }
    }
    
    func forgetConfig(_ peripheral: CBMPeripheralSpec) {
        self.sendResponse(peripheral, requestCode: .forgetConfig)
    }
    
    private func sendFailReason(_ peripheral: CBMPeripheralSpec, reason: ConnectionFailureReason) {
        let states: [ConnectionState] = [.authentication, .association, .obtainingIp, .connected]
        
        switch reason {
        case .authError:
            sendConnectionStates(peripheral, connectionStatuses: Array(states.prefix(1)))
        case .networkNotFound:
            sleep(2)
        case .timeout:
            sleep(3)
        case .failIp:
            sendConnectionStates(peripheral, connectionStatuses: Array(states.prefix(3)))
            sleep(1)
        case .failConn:
            sendConnectionStates(peripheral, connectionStatuses: Array(states.prefix(3)))
            sleep(1)
        case .unknown:
            break
        }
        
        let result = self.result(reason: reason.proto)
        peripheral.simulateValueUpdate(result, for: .dataOut)
    }
    
    private func sendConnectionStates(_ peripheral: CBMPeripheralSpec, connectionStatuses: [ConnectionState]) {
        for status in connectionStatuses {
            let result = self.result(state: status.proto)
            peripheral.simulateValueUpdate(result, for: .dataOut)
            msleep(connectionTimeInterval)
        }
    }
    
    private func sendResponse(_ peripheral: CBMPeripheralSpec, deviceStatus: Proto.DeviceStatus? = nil, status: Proto.Status? = .success, requestCode: Proto.OpCode, handler: (() -> ())? = nil) {
        self.queue.asyncAfter(deadline: .now() + requestTimeInterval) { [weak self] in
            guard let `self` = self else { return }
            
            let response = self.response(deviceStatus: deviceStatus, status: status, requestCode: requestCode)
            peripheral.simulateValueUpdate(response, for: .controlPoint)
            
            handler?()
        }
    }
    
    // MARK: - Respense and Result
    func response(deviceStatus: Proto.DeviceStatus? = nil, status: Proto.Status? = .success, requestCode: Proto.OpCode) -> Data {
        var response = Proto.Response()
        response.requestOpCode = requestCode
        
        if let status {
            response.status = status
        }
        
        if let deviceStatus {
            response.deviceStatus = deviceStatus
        }
        
        return try! response.serializedData()
    }
    
    func result(scanRecord: Proto.ScanRecord? = nil, state: Proto.ConnectionState? = nil, reason: Proto.ConnectionFailureReason? = nil) -> Data {
        var result = Proto.Result()
        
        if let scanRecord {
            result.scanRecord = scanRecord
        }
        
        if let state {
            result.state = state
        }
        
        if let reason {
            result.reason = reason
        }
        
        return try! result.serializedData()
    }
}

extension MockDevice: CBMPeripheralSpecDelegate {
    public func peripheralDidReceiveConnectionRequest(_ peripheral: CBMPeripheralSpec) -> Result<Void, Error> {
        return .success(())
    }
    
    public func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?) -> Result<Void, Error> {
        return .success(())
    }
    
    public func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveCharacteristicsDiscoveryRequest characteristicUUIDs: [CBMUUID]?, for service: CBMServiceMock) -> Result<Void, Error> {
        return .success(())
    }
    
    public func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor characteristic: CBMCharacteristicMock) -> Result<Data, Error> {
        if characteristic.uuid == CharacteristicID.version.cbm {
            var info = Proto.Info()
            info.version = UInt32(self.version)
            return .success(try! info.serializedData())
        } else {
            fatalError("peripheral(_:didReceiveReadRequestFor: \(characteristic) has not been implemented")
        }
    }
    
    public func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristicMock, data: Data) -> Result<Void, Error> {
        if characteristic.uuid == CharacteristicID.controlPoint.cbm {
            parseWriteData(data, peripheral: peripheral)
            return .success(())
        } else {
            fatalError()
        }
    }
    
    public func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristicMock) -> Result<Void, Error> {
        if characteristic.uuid == CharacteristicID.controlPoint.cbm {
            return .success(())
        } else if characteristic.uuid == CharacteristicID.dataOut.cbm {
            return .success(())
        } else {
            fatalError()
        }
    }
}
