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
import os

class DeviceViewModel: ObservableObject {
    @Published(initialValue: "") private (set) var deviceName: String

    /// The current bluetooth state of the device.
    @Published(initialValue: .connecting) fileprivate(set) var connectionStatus: ConnectionState

    @Published(initialValue: false) private (set) var provisioningInProgress: Bool
	@Published(initialValue: nil) fileprivate(set) var wifiState: Provisioner.WiFiStatus? {
        didSet {
            provisioningInProgress = wifiState?.isInProgress ?? false
            updateButtonState()

            switch wifiState {
            case .connectionFailed(let e):
                provisioningError = conventConnectionFailure(e)
            default:
                provisioningError = nil
            }
        }
    }
    @Published(initialValue: nil) private (set) var provisioningError: ReadableError?

	@Published(initialValue: "Unknown") fileprivate(set) var version: String

    @Published(initialValue: false) var showAccessPointList: Bool
    @Published(initialValue: [:]) fileprivate(set) var accessPoints: [String : AccessPoint]
    @Published(initialValue: nil) var selectedAccessPoint: AccessPoint? {
        didSet {
            passwordRequired = selectedAccessPoint?.isOpen == false
            updateButtonState()
            
            showAccessPointList = false
            Task {
                try? await activeAccessPointVM?.stopScan()
                activeAccessPointVM = nil
            }
        }
    }
    @Published(initialValue: false) private(set) var passwordRequired: Bool
    @Published var password: String = "" {
        didSet {
            updateButtonState()
        }
    }
    @Published var buttonState: ProvisionButtonState = ProvisionButtonState(isEnabled: false, title: "Connect", style: NordicButtonStyle())
    @Published(initialValue: false) var forceShowProvisionInProgress: Bool
    @Published(initialValue: false) var isScanning: Bool

    private var cancellable: Set<AnyCancellable> = []

    let provisioner: Provisioner
    let peripheralId: UUID
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "nordic", category: "DeviceViewModel")

    private var activeAccessPointVM: AccessPointListViewModel?
    var accessPointListViewModel: AccessPointListViewModel {
        if let vm = activeAccessPointVM {
            return vm
        }
        let vm = AccessPointListViewModel(provisioner: provisioner)
        activeAccessPointVM = vm
        vm.$selectedAccessPoint
                .receive(on: DispatchQueue.main)
                .sink { [weak self] selection  in
                    if let ap = selection {
                        self?.selectedAccessPoint = ap
                    }
                }
                .store(in: &cancellable)
        return vm
    }
    
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
        if case .connected = connectionStatus {
            return
        }

        provisioner.bluetoothConnectionStates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
            self?.connectionStatus = state.toConnectionState()
                    self?.logger.info("Bluetooth connection state: \(state)")
                    if case .connected = state {

                    } else {
                        // reset
                        /*
                        self?.wifiState = nil
                        self?.accessPoints = []
                        self?.selectedAccessPoint = nil
                        self?.password = ""
                        self?.version = "Unknown"
                         */
                    }
        }.store(in: &cancellable)

        do {
            try await provisioner.connect()
            DispatchQueue.main.async {
                self.connectionStatus = .connected
            }
        } catch let e as BluetoothConnectionError {
            switch e {
            case .canNotConnect:
                try rethrowError(TitleMessageError(title: "Can not connect", message: "Please check if your device is turned on and in range."))
            case .versionCharacteristicNotFound:
                try rethrowError(TitleMessageError(title: "Version Characteristic Not Found", message: "Please check if your device has the correct firmware installed."))
            case .controlCharacteristicPointNotFound:
                try rethrowError(TitleMessageError(title: "Control Characteristic Not Found", message: "Please check if your device has the correct firmware installed."))
            case .dataOutCharacteristicNotFound:
                try rethrowError(TitleMessageError(title: "Data Out Characteristic Not Found", message: "Please check if your device has the correct firmware installed."))
            case .wifiServiceNotFound:
                try rethrowError(TitleMessageError(title: "Wi-Fi Service Not Found", message: "Please check if your device has the correct firmware installed."))
            case .unknownError:
                try rethrowError(TitleMessageError(title: "Unknown Error", message: "Something went wrong."))
            case .commonError(let e):
                try rethrowError(TitleMessageError(title: "Error", message: e.localizedDescription))
            }
        } catch {
            try rethrowError(TitleMessageError(title: "Unknown Error", message: "Something went wrong."))
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

    func stopScan() async throws {
        do {
            try await provisioner.stopScan()
            DispatchQueue.main.async {
                self.isScanning = false
                self.accessPoints.removeAll()
            }
        } catch {
            // TODO: Show error HUD
            try rethrowError(TitleMessageError(title: "Error", message: "Something went wrong."))
        }
    }

    func startProvision() async throws {
        let statePublisher = try await provisioner.startProvision(accessPoint: selectedAccessPoint!, passphrase: password.isEmpty ? nil : password)
        DispatchQueue.main.async {
            self.buttonState.isEnabled = false
            self.forceShowProvisionInProgress = true
        }

        for try await state in statePublisher.values {
            DispatchQueue.main.async { [weak self] in
                self?.wifiState = state
                // turn off provisioning in progress when we get first state
                // then progress indicator will depend on state
                self?.forceShowProvisionInProgress = false
            }
        }
    }
}

extension DeviceViewModel {
    private func rethrowError(_ error: ReadableError) throws -> Never {
        DispatchQueue.main.async {
            // TODO: Show error placeholder
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

    private func conventConnectionFailure(_ reason: Provisioner.WiFiStatus.ConnectionFailure) -> ReadableError {
        switch reason {
        case .authError:
            return TitleMessageError(title: "Authentication Error", message: "Please check your password.")
        case .networkNotFound:
            return TitleMessageError(title: "Network Not Found", message: "Please check your network name.")
        case .timeout:
            return TitleMessageError(title: "Timeout", message: "Timeout while connecting to the network.")
        case .failIp:
            return TitleMessageError(title: "IP Error", message: "Error obtaining IP address.")
        case .failConn:
            return TitleMessageError(title: "Connection Error", message: "Please check your network name and password.")
        case .unknown:
            return TitleMessageError(title: "Unknown Error", message: "Something went wrong.")
        }
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
