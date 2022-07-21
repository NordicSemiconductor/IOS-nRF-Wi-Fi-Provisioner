import Foundation
import AsyncBluetooth
import os

public class Provisioner {
    public enum Error: Swift.Error {
        case canNotConnect
        case wifiServiceNotFound
        case versionCharacteristicNotFound
        case controlCharacteristicPointNotFound
        case dataOutCharacteristicNotFoind
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
        category: "provisioner"
    )
    
    private let centralManager = CentralManager()
    
    private var peripheral: Peripheral!
    private var wifiService: AsyncBluetooth.Service!
    private var versienCharacteristic: Characteristic!
    private var controlPointCharacteristic: Characteristic!
    private var dataOutCharacteristic: Characteristic!
    
    public let deviceID: UUID
    
    public init(deviceID: UUID) {
        self.deviceID = deviceID
    }
    
    public func parseScanData(_ scanData: ScanData) -> ScanDataInfo {
        let advData = AdvertisementData(scanData.advertisementData)
        print(advData)
        return ScanDataInfo()
    }
    
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
        
        let characteristicIds: [UUID] = [Service.Characteristic.version, Service.Characteristic.controlPoint, Service.Characteristic.dataOut]
        try await peripheral
            .discover(
                characteristics: characteristicIds,
                for: wifiService
            )
        
        self.versienCharacteristic = try lookUpCharacteristic(Service.Characteristic.version, in: wifiService, peripheral: peripheral, throwIfNotFound: .versionCharacteristicNotFound)
        self.controlPointCharacteristic = try lookUpCharacteristic(Service.Characteristic.controlPoint, in: wifiService, peripheral: peripheral, throwIfNotFound: .controlCharacteristicPointNotFound)
        self.dataOutCharacteristic = try lookUpCharacteristic(Service.Characteristic.dataOut, in: wifiService, peripheral: peripheral, throwIfNotFound: .dataOutCharacteristicNotFoind)
    }
    
    private func lookUpCharacteristic(_ characteristicId: UUID, in service: AsyncBluetooth.Service, peripheral: Peripheral, throwIfNotFound error: Error) throws -> Characteristic {
        
        guard let service = peripheral.discoveredServices?.first(where: { $0.identifier == service.identifier }) else {
            throw error
        }
        
        guard let characteristic = service.discoveredCharacteristics?.first(where: { $0.identifier == characteristicId }) else {
            throw error
        }
        return characteristic
    }
    
}
 
