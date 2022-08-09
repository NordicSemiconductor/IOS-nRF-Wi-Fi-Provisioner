//
//  DeviceViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import Foundation
import Provisioner
import Combine
import NordicStyle

class DeviceViewModel: ObservableObject {
    struct ButtonState {
        var isEnabled: Bool
        var title: String
        var style: NordicButtonStyle
    }

    enum ConnectionState: CustomStringConvertible {
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
    @Published fileprivate(set) var connectionError: ReadableError? {
        didSet {
            showErrorAlert = true
            connectionError.map { self.connectionStatus = .failed($0) }
        }
    }
    @Published private (set) var deviceName: String = ""

    /// The current bluetooth state of the device.
    @Published fileprivate(set) var connectionStatus: ConnectionState = .connecting

    @Published private (set) var provisioningInProgress: Bool = false
	@Published fileprivate(set) var wifiState: Provisioner.WiFiStatus? = nil {
        didSet {
            provisioningInProgress = wifiState?.isInProgress ?? false
            updateButtonState()
        }
    }
	@Published fileprivate(set) var version: String = "Unknown"

    @Published var showAccessPointList: Bool = false
    @Published fileprivate(set) var accessPoints: [AccessPoint] = []
    @Published var selectedAccessPoint: AccessPoint? {
        didSet {
            passwordRequired = selectedAccessPoint?.isOpen == false
            updateButtonState()
        }
    }
    @Published private(set) var passwordRequired: Bool = false
    @Published var password: String = "" {
        didSet {
            updateButtonState()
        }
    }
    @Published var buttonState: ButtonState = ButtonState(isEnabled: false, title: "Connect", style: NordicButtonStyle())

    private var cancellable: Set<AnyCancellable> = []

    let provisioner: Provisioner
    let peripheralId: UUID
    
    init(peripheralId: UUID) {
        self.peripheralId = peripheralId
        self.provisioner = Provisioner(deviceID: peripheralId)
        deviceName = "Wi-Fi Device"
    }

    init(provisioner: Provisioner) {
        self.peripheralId = provisioner.deviceID
        self.provisioner = provisioner
        deviceName = "Wi-Fi Device"
	}

    func connect() async throws {
        do {
            try await provisioner.connect()
            DispatchQueue.main.async {
                self.connectionStatus = .connected
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
            self.wifiState = status
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
            DispatchQueue.main.async {
                self.accessPoints.removeAll()
            }
        } catch {
            try rethrowError(Error.canNotStopScan)
        }
    }

    func startProvision() async throws {
        let statePublisher = try await provisioner.startProvision(accessPoint: selectedAccessPoint!, passphrase: password.isEmpty ? nil : password)

        for try await state in statePublisher.values {
            DispatchQueue.main.async {
                self.wifiState = state
            }
        }
    }
}

extension DeviceViewModel {
    private func rethrowError(_ error: ReadableError) throws -> Never {
        DispatchQueue.main.async {
            self.connectionError = error
        }
        throw error
    }

    private func updateButtonState() {
        let enabled = wifiState?.isInProgress != true
                && selectedAccessPoint != nil
                && (password.count >= 6 || !passwordRequired)

        buttonState.isEnabled = enabled

        let title = { () -> String in
            let oldTitle = buttonState.title
            let state = wifiState ?? .disconnected
            if state.isInProgress {
                return oldTitle
            }
            switch state {
            case .disconnected:
                return "Provision"
            case .connectionFailed(_):
                return "Try Again"
            case .connected:
                return "Re-provision"
            default:
                return oldTitle
            }
        }()

        buttonState.title = title
    }
}

#if DEBUG
class MockProvisioner: Provisioner {
    init() {
        super.init(deviceID: UUID())
    }

    override func readVersion() async throws -> String? {
        return "14"
    }

    override func getStatus() async throws -> Provisioner.WiFiStatus {
        return .disconnected
    }
}

class MockDeviceViewModel: DeviceViewModel {
    var i: Int? = 0
    
    init(index: Int) {
        super.init(provisioner: MockProvisioner())
        self.i = index
        
        let states: [ConnectionState] = [.connecting, .connected, .failed(TitleMessageError(message: "Failed to retreive required services"))]
        
        self.connectionStatus = states[index % 3]
    }
    
    override func connect() async throws {
        self.connectionStatus = .connected
        self.wifiState = .disconnected
        self.version = "14"
        
    }
}
#endif
