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
        
        case noResponse
        case unknownDeviceStatus
    }
    
    public enum WiFiStatus {
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
        
        self.versionCharacteristic = try lookUpCharacteristic(Service.Characteristic.version, in: wifiService, peripheral: peripheral, throwIfNotFound: .versionCharacteristicNotFound)
        self.controlPointCharacteristic = try lookUpCharacteristic(Service.Characteristic.controlPoint, in: wifiService, peripheral: peripheral, throwIfNotFound: .controlCharacteristicPointNotFound)
        self.dataOutCharacteristic = try lookUpCharacteristic(Service.Characteristic.dataOut, in: wifiService, peripheral: peripheral, throwIfNotFound: .dataOutCharacteristicNotFound)
        
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
        guard let responseData = try await sendRequestToDataPoint(opCode: .getStatus) else {
            throw Error.noResponse
        }
        
        let response = try Response(serializedData: responseData)
        guard response.status == .success else {
            logger.error("No response in for .getStatus")
            throw Error.unknownDeviceStatus
        }
        guard response.hasDeviceStatus else {
            logger.error("Response has no device status")
            throw Error.unknownDeviceStatus
        }
        
        return response.deviceStatus.toPublicStatus()
    }
    
    public func startScan() async throws -> AnyPublisher<AccessPoint, Swift.Error> {
        var request = Request()
        request.opCode = .startScan
        
        let data = try request.serializedData()
            
        try await peripheral.writeValue(data, for: controlPointCharacteristic, type: .withResponse)
        
        let ap = peripheral.characteristicValueUpdatedPublisher
            .filter { $0.identifier == self.dataOutCharacteristic.identifier }
            .map(\.value)
            .tryMap { resp -> AccessPoint in
                guard let responseData = resp as Data? else {
                    self.logger.error("No response data in wifi scan")
                    throw Error.noResponse
                }
                
                let response = try Result(serializedData: responseData)
                let wifiInfo = response.scanRecord.wifi
                let wifiName = String(data: wifiInfo.ssid, encoding: .utf8)
                let isOpen = wifiInfo.auth.isOpen
                let channel = Int(wifiInfo.channel)
                let rssi = Int(response.scanRecord.rssi)

                self.logger.debug("Wifi ap response received: \(response.scanRecord.wifi.debugDescription)")
                
                return AccessPoint(name: wifiName ?? "n/a", isOpen: isOpen, channel: channel, rssi: rssi)
            }
            .eraseToAnyPublisher()

        try await peripheral.setNotifyValue(true, for: dataOutCharacteristic)
        
        return ap
    }
    
    public func stopScan() async throws {
        try await sendRequestToDataPoint(opCode: .stopScan)
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
    private func sendRequestToDataPoint(opCode: OpCode) async throws -> Data? {
        logger.debug("Sending command \(opCode.debugDescription)")
        var request = Request()
        request.opCode = opCode
        
        do {
            let data = try request.serializedData()
            
            try await peripheral.writeValue(data, for: controlPointCharacteristic, type: .withResponse)
            
            let valueReceiver = peripheral.characteristicValueUpdatedPublisher
                .filter { $0.identifier == self.controlPointCharacteristic.identifier }
                .map(\.value)
            
            try await peripheral.writeValue(data, for: controlPointCharacteristic, type: .withResponse)
            return await valueReceiver.values.first(where: {_ in true }) ?? nil
        } catch let e {
            logger.error("Error while sending command: \(e.localizedDescription)")
            throw e
        }
    }
}
