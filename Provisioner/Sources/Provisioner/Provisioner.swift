import Foundation
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

    public let deviceID: UUID
    
    public init(deviceID: UUID) {
        self.deviceID = deviceID
    }
}

extension Provisioner {
    open func connect() async throws {
        _ = try await centralManager.connectPeripheral(deviceID)
    }
    
    open func readVersion() async throws -> String? {
        let versionData: Data? = try await centralManager.readValue(for: centralManager.versionCharacteristic)
        
        let version = try Info(serializedData: versionData!).version
        
        logger.info("Read version: \(version, privacy: .public)")
        
        return "\(version)"
    }
    
    open func getStatus() async throws -> WiFiStatus {

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
    
    open func startScan() async throws -> AnyPublisher<AccessPoint, Swift.Error> {
        var wfInfo = WifiInfo()
        wfInfo.ssid = "test".data(using: .utf8)!

        return Just(AccessPoint(wifiInfo: wfInfo, RSSI: -90))
                .mapError { $0 as! Error }
                .eraseToAnyPublisher()
        /*
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

                self.logger.info("Wifi ap response received: \(response.scanRecord.wifi.debugDescription)")
                
                return AccessPoint(wifiInfo: wifiInfo, RSSI: response.scanRecord.rssi)
            }
            .eraseToAnyPublisher()

        try await peripheral.setNotifyValue(true, for: dataOutCharacteristic)
        
        return accessPointPublisher

         */
    }
    
    open func stopScan() async throws {
        try await sendRequestToDataPoint(opCode: .stopScan)
    }

    open func startProvision(accessPoint: AccessPoint, passphrase: String?) async throws -> AnyPublisher<WiFiStatus, Swift.Error> {
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
                    self.logger.info("Wifi state response received: \(state.debugDescription)")
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
    @discardableResult
    private func sendRequestToDataPoint(opCode: OpCode, config: WifiConfig? = nil) async throws -> Response {
        logger.info("Sending command \(opCode.debugDescription, privacy: .public), config: \(config?.debugDescription ?? "nil", privacy: .public)")
        var request = Request()
        request.opCode = opCode
        if let config = config {
            request.config = config
        }
        
        do {
            let data = try request.serializedData()
            logger.info("Sending command \(opCode.debugDescription) with data: \(try! request.jsonString(), privacy: .public)")

            let valueReceiver = peripheral.characteristicValueUpdatedPublisher
                    .filter {
                        self.logger.debug("Received value for characteristic: \($0.identifier, privacy: .public)")
                        return $0.identifier == self.controlPointCharacteristic.identifier
                    }
                    .map(\.value)
                    .tryMap { (data: Data?) -> Response in
                        // Log data
                        self.logger.debug("Received response data: \(data?.debugDescription ?? "nil", privacy: .public)")
                        guard let data = data else {
                            throw Error.noResponse
                        }
                        return try Response(serializedData: data)
                    }
                    .first { $0.requestOpCode == opCode }

            try await peripheral.setNotifyValue(true, for: controlPointCharacteristic)
            try await peripheral.writeValue(data, for: controlPointCharacteristic, type: .withoutResponse)
//            try await peripheral.writeValue(data, forCharacteristicWithUUID: controlPointCharacteristic.identifier, ofServiceWithUUID: wifiService.identifier, type: .withResponse)

            for try await value in valueReceiver.values {
                logger.debug("Received response in a loop: \(try! value.jsonString(), privacy: .public)")
            }

            guard let response = try await valueReceiver.values.first(where: { _ in true }) else {
                logger.error("No response data")
                throw Error.noResponse
            }
            logger.info("Response received: \(try! response.jsonString(), privacy: .public)")
            return response
        } catch let e {
            logger.error("Error while sending command: \(e.localizedDescription, privacy: .public)")
            throw e
        }
    }
}
