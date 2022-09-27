import Foundation
import os
import SwiftProtobuf
import CoreBluetoothMock
import Combine

extension Provisioner {
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

        public struct Service {
            public static let wifi = UUID(uuidString: "14387800-130c-49e7-b877-2881c89cb258")!

            public struct Characteristic {
                public static let version = UUID(uuidString: "14387801-130c-49e7-b877-2881c89cb258")!
                public static let controlPoint = UUID(uuidString: "14387802-130c-49e7-b877-2881c89cb258")!
                public static let dataOut = UUID(uuidString: "14387803-130c-49e7-b877-2881c89cb258")!
            }
        }
    }

    /// The current bluetooth device connection status.
    public enum BluetoothConnectionStatus {
        case disconnected
        case connected
        case connecting
        case connectionCanceled(Reason)

        public enum Reason {
            case error(Swift.Error)
            case byRequest
        }
    }
}

open class Provisioner {
    private let logger = Logger(
            subsystem: Bundle(for: Provisioner.self).bundleIdentifier ?? "",
            category: "provisioner-manager"
    )

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

    open func getStatus() async throws -> WiFiStatus {
        let response = (try await sendRequestToDataPoint(opCode: .getStatus))
        guard case .success = response.status else {
            throw ProvisionError.unknownDeviceStatus
        }
        return response.deviceStatus.state.toPublicStatus()
    }

    open func startScan() async throws -> AnyPublisher<AccessPoint, Swift.Error> {
        logger.info("start scan")
        let response = (try await sendRequestToDataPoint(opCode: .startScan))
        guard case .success = response.status else {
            throw ProvisionError.requestFailed
        }
        return centralManager.dataOutStream
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
                .tryPrefix { status in
                    switch status {
                    case .connected, .connectionFailed:
                        throw InternalError(status: status)
                    default:
                        return true
                    }
                }
                .tryCatch { error -> AnyPublisher<WiFiStatus, Never> in
                    if let e = error as? InternalError {
                        return Just(e.status).eraseToAnyPublisher()
                    } else {
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
