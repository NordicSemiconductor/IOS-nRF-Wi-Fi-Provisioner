import Foundation
import os
import SwiftProtobuf
import CoreBluetoothMock
import Combine

open class Provisioner {
    private let logger = Logger(
            subsystem: Bundle(for: Provisioner.self).bundleIdentifier ?? "",
            category: "provisioner-manager"
    )

    private var cancelables = Set<AnyCancellable>()
    private let centralManager = CentralManager()

    public let deviceID: UUID

    public var bluetoothConnectionStates: AnyPublisher<BluetoothConnectionStatus, Never> {
        centralManager.connectionStateSubject.eraseToAnyPublisher()
    }

    public init(deviceID: UUID) {
        self.deviceID = deviceID
    }

    open func connect() async throws {
        do {
            _ = try await centralManager.connectPeripheral(deviceID)
        } catch let e {
            logger.error("failed to connect to device: \(e.localizedDescription)")
            throw BluetoothConnectionError.commonError(error: e)
        }
    }

    open func readVersion() async throws -> String? {
        let versionData: Data? = try await centralManager.readValue(for: .version)

        let version = try Info(serializedData: versionData!).version

        logger.info("Read version: \(version, privacy: .public)")

        return "\(version)"
    }

    open func getStatus() async throws -> WiFiDeviceStatus {
        let response = (try await sendRequestToDataPoint(opCode: .getStatus))
        guard case .success = response.status else {
            throw ProvisionError.unknownDeviceStatus
        }
        
        return WiFiDeviceStatus(deviceStatus: response.deviceStatus)
    }

    open func startScan() -> AnyPublisher<AccessPoint, Swift.Error> {
        logger.info("start scan")
        
        struct ImpossibleError: Error {}
        
        let future = Future<Bool, Swift.Error> { promise in
            Task {
                let response = (try await self.sendRequestToDataPoint(opCode: .startScan))
                if case .success = response.status {
                    promise(.success((true)))
                } else {
                    promise(.failure(ProvisionError.requestFailed))
                }
            }
        }
        
        return self.centralManager.dataOutStream.combineLatest(future)
            .scan((Array<Data>(), false)) { old, value -> (Array<Data>, Bool) in
                var oldValue = old
                oldValue.1 = value.1
                oldValue.0.append(value.0)
                return oldValue
            }
            .compactMap { val -> [Data]? in
                if val.1 {
                    return val.0
                } else {
                    return nil
                }
            }
            .flatMap { dataSeq -> Publishers.Sequence<[Data], Error> in
                self.logger.debug("Assigned access points: - \(dataSeq.count)")
                return Publishers.Sequence(sequence: dataSeq)
            }
            .compactMap { [weak self] data -> AccessPoint? in
                guard let result = try? Result(serializedData: data) else {
                    return nil
                }
                self?.logger.debug("Read data: \(try! result.jsonString(), privacy: .public)")
                guard result.hasScanRecord else {
                    return nil
                }
                let wifiInfo = result.scanRecord.wifi
                return AccessPoint(wifiInfo: wifiInfo, RSSI: result.scanRecord.rssi)
            }
            .eraseToAnyPublisher()
    }

    open func stopScan() async throws {
        try await sendRequestToDataPoint(opCode: .stopScan)
    }

    open func startProvision(accessPoint: AccessPoint, passphrase: String?, volatileMemory: Bool) async throws -> AnyPublisher<WiFiStatus, Swift.Error> {
        var config = WifiConfig()
        config.wifi = accessPoint.wifiInfo
        config.volatileMemory = volatileMemory

        if let passphrase = passphrase {
            config.passphrase = passphrase.data(using: .utf8)!
        }

        struct InternalError: Swift.Error {
            let status: WiFiStatus
        }

        // WiFiStatus publisher
        let statusPublisher = centralManager.dataOutStream
                .compactMap { [weak self] data -> WiFiStatus? in
                    guard let result = try? Result(serializedData: data), result.hasState else {
                        return nil
                    }
                    
                    self?.logger.debug("Read data: \(try! result.jsonString(), privacy: .public)")
                    return result.state.toPublicStatus(withReason: result.reason)
                }.timeout(.seconds(60), scheduler: DispatchQueue.main) { TimeoutError() }
                .replaceError(with: .connectionFailed(.timeout))
                // 1 - get prefixes until state is connected
                .tryPrefix { status in
                    switch status {
                    // 2 - if state is connected or failed throw InternalError.
                    // We can not just return false, because steam will be closed without sending 'connected' state
                    // Note: InternalError is a special structure which is used only in this method
                    case .connected, .connectionFailed:
                        throw InternalError(status: status)
                    default:
                        return true
                    }
                }
                .tryCatch { error -> AnyPublisher<WiFiStatus, Never> in
                    if let e = error as? InternalError {
                        // 3 - if wi got `InternalError` just replace it with state it contains inside.
                        return Just(e.status).eraseToAnyPublisher()
                    } else {
                        // 4 - Else: rethrow error
                        throw error
                    }
                }
                .eraseToAnyPublisher()

        // Send request
        let response = try await sendRequestToDataPoint(opCode: .setConfig, config: config)
        guard case .success = response.status else {
            throw ProvisionError.requestFailed
        }

        return statusPublisher
    }
    
    open func unprovision() {
        
    }
}

extension Provisioner {
    @discardableResult
    private func sendRequestToDataPoint(opCode: OpCode, config: WifiConfig? = nil) async throws -> Response {
        var request = Request()
        request.opCode = opCode
        if let conf = config {
            request.config = conf
        }

        let data = try request.serializedData()
        let responseData = try await centralManager.writeValue(data, for: .controlPoint)
        let response = try Response(serializedData: responseData)
        logger.debug("Response: \(try! response.jsonString(), privacy: .public)")
        return response
    }
}
