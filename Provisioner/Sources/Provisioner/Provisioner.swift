import Foundation
import AsyncBluetooth
import os
import SwiftProtobuf
import CoreBluetoothMock
import Combine

public class Provisioner {
    public enum Error: Swift.Error {
        case canNotConnect
        case wifiServiceNotFound
        case versionCharacteristicNotFound
        case controlCharacteristicPointNotFound
        case dataOutCharacteristicNotFound
        case requestFailed
        
        case noResponse
        case unknownDeviceStatus
    }
    
    public enum WiFiStatus: CustomDebugStringConvertible {
        case disconnected
        case authentication
        case association
        case obtainingIp
        case connected
        case connectionFailed(ConnectionFailure)
        
        public enum ConnectionFailure {
            case authError
            case networkNotFound
            case timeout
            case failIp
            case failConn
            case unknown
        }

        public var debugDescription: String {
            switch self {
            case .disconnected: return "disconnected"
            case .authentication: return "authentication"
            case .association: return "association"
            case .obtainingIp: return "obtainingIp"
            case .connected: return "connected"
            case .connectionFailed(let reason): return "connectionFailed: \(reason)"
            }
        }
    }
    
    public struct Service {
        public static let wifi = UUID(uuidString: "14387800-130c-49e7-b877-2881c89cb258")!
        
        public struct Characteristic {
            public static let version = UUID(uuidString: "14387801-130c-49e7-b877-2881c89cb258")!
            public static let controlPoint = UUID(uuidString: "14387802-130c-49e7-b877-2881c89cb258")!
            public static let dataOut = UUID(uuidString: "14387803-130c-49e7-b877-2881c89cb258")!
        }
    }
    
    private let logger = Logger(
        subsystem: Bundle(for: Provisioner.self).bundleIdentifier ?? "",
        category: "provisioner-manager"
    )
    
    private let centralManager = CentralManager()
    
    private var peripheral: Peripheral!
    private var wifiService: AsyncBluetooth.Service!
    private var versionCharacteristic: Characteristic!
    private var controlPointCharacteristic: Characteristic!
    private var dataOutCharacteristic: Characteristic!
    
    public let deviceID: UUID
    
    public init(deviceID: UUID) {
        self.deviceID = deviceID
    }
}

extension Provisioner {
    public func connect() async throws {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [deviceID]).first else {
            throw Error.canNotConnect
        }
        
        self.peripheral = peripheral
        
        do {
            try await centralManager.connect(peripheral)
        } catch {
            logger.error("")
            throw Error.canNotConnect
        }
        
        // Discover WiFi service
        do {
            try await peripheral.discoverServices([Service.wifi])
        } catch {
            try await centralManager.cancelPeripheralConnection(peripheral)
            throw Error.wifiServiceNotFound
        }
        
        guard let wifiService = peripheral.discoveredServices?.first(where: {
            $0.identifier == Service.wifi
        }) else {
            throw Error.wifiServiceNotFound
        }
        
        self.wifiService = wifiService
        
        let characteristicIds: [UUID] = [Service.Characteristic.version, Service.Characteristic.controlPoint, Service.Characteristic.dataOut]
        try await peripheral
            .discover(
                characteristics: characteristicIds,
                for: wifiService
            )
        
        versionCharacteristic = try lookUpCharacteristic(Service.Characteristic.version, in: wifiService, peripheral: peripheral, throwIfNotFound: .versionCharacteristicNotFound)
        controlPointCharacteristic = try lookUpCharacteristic(Service.Characteristic.controlPoint, in: wifiService, peripheral: peripheral, throwIfNotFound: .controlCharacteristicPointNotFound)
        dataOutCharacteristic = try lookUpCharacteristic(Service.Characteristic.dataOut, in: wifiService, peripheral: peripheral, throwIfNotFound: .dataOutCharacteristicNotFound)
        
        try await peripheral.setNotifyValue(true, for: dataOutCharacteristic)
    }
    
    public func readVersion() async throws -> String? {
        let versionData: Data? = try await peripheral.readValue(
            forCharacteristicWithUUID: versionCharacteristic.identifier,
            ofServiceWithUUID: wifiService.identifier
        )
        
        let version = try Info(serializedData: versionData!).version
        
        logger.debug("Read version: \(version, privacy: .public)")
        
        return "\(version)"
    }
    
    public func getStatus() async throws -> WiFiStatus {
        let response = try await sendRequestToDataPoint(opCode: .getStatus)
        guard case .success = response.status else {
            throw Error.requestFailed
        }

        guard response.hasDeviceStatus else {
            logger.error("Response has no device status")
            throw Error.unknownDeviceStatus
        }
        
        return response.deviceStatus.state.toPublicStatus(withReason: response.deviceStatus.reason)
    }
    
    public func startScan() async throws -> AnyPublisher<AccessPoint, Swift.Error> {
        var request = Request()
        request.opCode = .startScan
        
        let data = try request.serializedData()
            
        try await peripheral.writeValue(data, for: controlPointCharacteristic, type: .withResponse)
        
        let accessPointPublisher = peripheral.characteristicValueUpdatedPublisher
            .filter { $0.identifier == self.dataOutCharacteristic.identifier }
            .map(\.value)
            .tryMap { resp -> AccessPoint in
                guard let responseData = resp as Data? else {
                    self.logger.error("No response data in wifi scan")
                    throw Error.noResponse
                }
                
                let response = try Result(serializedData: responseData)
                let wifiInfo = response.scanRecord.wifi

                self.logger.debug("Wifi ap response received: \(response.scanRecord.wifi.debugDescription)")
                
                return AccessPoint(wifiInfo: wifiInfo, RSSI: response.scanRecord.rssi)
            }
            .eraseToAnyPublisher()

        try await peripheral.setNotifyValue(true, for: dataOutCharacteristic)
        
        return accessPointPublisher
    }
    
    public func stopScan() async throws {
        try await sendRequestToDataPoint(opCode: .stopScan)
    }

    public func startProvision(accessPoint: AccessPoint, passphrase: String?) async throws -> AnyPublisher<WiFiStatus, Swift.Error> {
        var wifiConfig = WifiConfig()
        wifiConfig.wifi = accessPoint.wifiInfo
        if let passphraseData = passphrase?.data(using: .utf8) {
            wifiConfig.passphrase = passphraseData
        }
        
        var request = Request()
        request.opCode = .setConfig
        request.config = wifiConfig
        
        let data = try request.serializedData()
        try await peripheral.writeValue(data, for: controlPointCharacteristic, type: .withResponse)

        let statePublisher = peripheral.characteristicValueUpdatedPublisher
                .filter { $0.identifier == self.dataOutCharacteristic.identifier }
                .map(\.value)
                .tryMap { data -> WiFiStatus in
                    guard let responseData = data as Data? else {
                        self.logger.error("No response data in wifi scan")
                        throw Error.noResponse
                    }

                    let result = try Result(serializedData: responseData)
                    let state = result.state.toPublicStatus()
                    self.logger.debug("Wifi state response received: \(state.debugDescription)")
                    return state
                }
        
        try await peripheral.setNotifyValue(true, for: dataOutCharacteristic)

//        let response = try await sendRequestToDataPoint(opCode: OpCode.setConfig, config: wifiConfig)
//
//        guard response.status == .success else {
//            logger.error("Failed to set wifi config")
//            throw Error.unknownDeviceStatus
//        }

        return statePublisher.eraseToAnyPublisher()
    }
}
 
extension Provisioner {
    private func lookUpCharacteristic(_ characteristicId: UUID, in service: AsyncBluetooth.Service, peripheral: Peripheral, throwIfNotFound error: Error) throws -> Characteristic {
        
        guard let service = peripheral.discoveredServices?.first(where: { $0.identifier == service.identifier }) else {
            throw error
        }
        
        guard let characteristic = service.discoveredCharacteristics?.first(where: { $0.identifier == characteristicId }) else {
            throw error
        }
        return characteristic
    }
    
    @discardableResult
    private func sendRequestToDataPoint(opCode: OpCode, config: WifiConfig? = nil) async throws -> Response {
        logger.debug("Sending command \(opCode.debugDescription)")
        var request = Request()
        request.opCode = opCode
        if let config = config {
            request.config = config
        }
        
        do {
            let data = try request.serializedData()
            logger.debug("Sending command \(opCode.debugDescription) with data: \(try! request.jsonString())")

            let valueReceiver = peripheral.characteristicValueUpdatedPublisher
                .filter { $0.identifier == self.controlPointCharacteristic.identifier }
                .map(\.value)
            
//            try await peripheral.writeValue(data, forCharacteristicWithUUID: controlPointCharacteristic.identifier, ofServiceWithUUID: wifiService.identifier, type: .withResponse)
            
            try await centralManager.retrieveConnectedPeripherals(withServices: [CBMUUID(nsuuid: peripheral.identifier)]).first?.writeValue(data, forCharacteristicWithUUID: controlPointCharacteristic.identifier, ofServiceWithUUID: wifiService.identifier, type: .withResponse)
            
            guard let responseData = await valueReceiver.values.first(where: {_ in true }) ?? nil else {
                logger.error("No response data")
                throw Error.noResponse
            }
            logger.debug("Command \(opCode.debugDescription) sent")

            let response = try Response(serializedData: responseData)

            logger.debug("Command \(opCode.debugDescription) response received: \(try! response.jsonString())")
            return response
        } catch let e {
            logger.error("Error while sending command: \(e.localizedDescription)")
            throw e
        }
    }
}
