//
//  DeviceViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import AsyncBluetooth
import Foundation
import Provisioner
import Combine

class DeviceViewModel: ObservableObject {
    enum WiFiStatus: CustomStringConvertible, Equatable {
        init(wifiState: Provisioner.WiFiStatus) {
            switch wifiState {
            case .connected: self = .connected
            case .association: self = .association
            case .authentication: self = .authentication
                    // TODO: Change Error
            case .connectionFailed(let reason): self = .failed(Error.canNotConnect)
            case .disconnected: self = .disconnected
            case .obtainingIp: self = .obtainingIp
            }
        }
        
        var description: String {
            switch self {
            case .connecting:
                return "Connecting ..."
            case .failed(let e):
                return e.message
            case .connected:
                return "Connected"
            case .disconnected:
                return "Disconnected"
            case .authentication:
                return "Authentication"
            case .association:
                return "Association"
            case .obtainingIp:
                return "Obtaining IP"
            }
        }

        static func == (lhs: WiFiStatus, rhs: WiFiStatus) -> Bool {
            switch (lhs, rhs) {
            case (.connecting, .connecting):
                return true
            case (.failed(let l), .failed(let r)):
                return true
            case (.connected, .connected):
                return true
            case (.disconnected, .disconnected):
                return true
            case (.authentication, .authentication):
                return true
            case (.association, .association):
                return true
            case (.obtainingIp, .obtainingIp):
                return true
            default:
                return false
            }
        }
        
		case connecting
		case failed(ReadableError)
		case connected
        case disconnected
        case authentication
        case association
        case obtainingIp
	}
    enum State: CustomStringConvertible {
        case connecting
        case failed(ReadableError)
        case connected

        var description: String {
            switch self {
            case .connecting:
                return "Connecting ..."
            case .failed(let e):
                return e.message
            case .connected:
                return "Connected"
            }
        }
    }

    enum Error: ReadableError {
        case canNotConnect
        case serviceNotFound
        case noResponse
        case canNotStopScan
        case canNotProvision
        
        var title: String? {
            switch self {
            case .canNotConnect:
                return "Connection failed"
            case .serviceNotFound:
                return "Wi-Fi Service not found"
            case .noResponse:
                return "No response"
            case .canNotStopScan:
                return "Can not stop scanning"
            case .canNotProvision:
                return "Can not provision"
            }
        }
        
        var message: String {
            switch self {
            case .canNotConnect:
                return "Can not connect the peripheral"
            case .serviceNotFound:
                return "You can not provision this device as there's no Wi-Fi service found."
            case .noResponse:
                return "Can not get response from the device"
            case .canNotStopScan:
                return "Can not stop scanning"
            case .canNotProvision:
                return "Provision failed"
            }
        }
    }

    // MARK: - Error
    @Published var showErrorAlert: Bool = false
    @Published fileprivate(set) var error: ReadableError? {
        didSet {
            showErrorAlert = true
            error.map { self.state = .failed($0) }
        }
    }
    @Published private (set) var deviceName: String = ""

    @Published fileprivate(set) var state: State = .connecting

	@Published fileprivate(set) var wifiState: WiFiStatus? = nil
	@Published fileprivate(set) var version: String = "Unknown"

    @Published var showAccessPointList: Bool = false
    @Published fileprivate(set) var accessPoints: [AccessPoint] = []
    @Published var selectedAccessPoint: AccessPoint? {
        didSet {
            passwordRequired = selectedAccessPoint?.isOpen == false
        }
    }
    @Published private(set) var passwordRequired: Bool = false
    @Published var password: String = ""

    private var cancellables: Set<AnyCancellable> = []

    let provisioner: Provisioner
    let peripheralId: UUID

	init(peripheralId: UUID, centralManager: CentralManager = CentralManager()) {
		self.peripheralId = peripheralId
        provisioner = Provisioner(deviceID: peripheralId)
        deviceName = CentralManager().retrievePeripherals(withIdentifiers: [self.peripheralId]).first?.name ?? "Prov"
	}

    func connect() async throws {
        do {
            try await provisioner.connect()
            DispatchQueue.main.async {
                self.state = .connected
            }
        } catch let e as Provisioner.Error {
            switch e {
            case .canNotConnect:
                try rethrowError(Error.canNotConnect)
            case .versionCharacteristicNotFound:
                fallthrough
            case .controlCharacteristicPointNotFound:
                fallthrough
            case .dataOutCharacteristicNotFound:
                fallthrough
            case .wifiServiceNotFound:
                try rethrowError(Error.serviceNotFound)
            case .noResponse:
                try rethrowError(Error.noResponse)
            case .unknownDeviceStatus:
                fatalError()
            case .requestFailed:
                try rethrowError(Error.noResponse)
            }
        } catch {
            try rethrowError(Error.canNotConnect)
        }
    }
}

extension DeviceViewModel {
    func readInformation() async throws {
        let v = try await provisioner.readVersion() ?? "Unknown"
        DispatchQueue.main.async {
            self.version = v
        }

        let status = try await provisioner.getStatus()

        DispatchQueue.main.async {
            switch status {
            case .disconnected, .authentication, .association, .obtainingIp:
                self.state = .connecting
            case .connected:
                self.state = .connected
            case .connectionFailed(_):
                self.state = .failed(Error.canNotConnect)
            }
        }
    }

    func startScan() async {
        DispatchQueue.main.async {
            self.accessPoints.removeAll()
        }
        do {
            for try await scanResult in try await provisioner.startScan().values {
                print(scanResult.ssid)
                DispatchQueue.main.async {
                    self.accessPoints.append(scanResult)
                }
            }
        } catch let e {
            print(e.localizedDescription)
        }
    }

    func stopScan() async throws {
        do {
            try await provisioner.stopScan()
        } catch {
            try rethrowError(Error.canNotStopScan)
        }
    }

    func startProvision() async throws {
        let statePublisher = try await provisioner.startProvision(accessPoint: selectedAccessPoint!, passphrase: password.isEmpty ? nil : password)

        for try await state in statePublisher.values {
            DispatchQueue.main.async {
                self.wifiState = WiFiStatus(wifiState: state)
            }
        }
    }
}

extension DeviceViewModel {
    private func rethrowError(_ error: ReadableError) throws -> Never {
        DispatchQueue.main.async {
            self.error = error
        }
        throw error
    }
}

#if DEBUG
class MockDeviceViewModel: DeviceViewModel {
    var i: Int? = 0
    
    init(index: Int) {
        super.init(peripheralId: UUID())
        self.i = index
        
        let states: [State] = [.connecting, .connected, .failed(TitleMessageError(message: "Failed to retreive required services"))]
        
        self.state = states[index % 3]
    }
    
    override init(peripheralId: UUID, centralManager: CentralManager = CentralManager()) {
        super.init(peripheralId: peripheralId, centralManager: centralManager)
    }
    
    override func connect() async throws {
        if i == 2 {
            error = Error.canNotConnect
            throw Error.canNotConnect            
        } else {
            Task {
                self.error = nil
            }
        }
    }
}
#endif
