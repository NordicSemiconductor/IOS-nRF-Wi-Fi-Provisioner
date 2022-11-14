//
//  DeviceViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import Foundation
import Combine
import NordicStyle
import os
import Provisioner2

protocol AccessPointSelection {
    var displayedWiFi: WifiInfo? { get set }
    var showAccessPointList: Bool { get set }
}

private let UnknownVersion = "Unknown"

class DeviceViewModel: ObservableObject, AccessPointSelection {
    private var versionResult: Swift.Result<Int, ProvisionerInfoError>? {
        didSet {
            guard let versionResult else { return }
            
            switch versionResult {
            case .success(let success):
                self.version = "\(success)"
            case .failure:
                // TODO: Display Error
                self.version = UnknownVersion
            }
        }
    }
    
    private var deviceStausResult: Swift.Result<DeviceStatus, ProvisionerError>? {
        didSet {
            guard let deviceStausResult else { return }
            
            switch deviceStausResult {
            case .success(let status):
                self.deviceStatus = status
            case .failure(_):
                // TODO: Handle bad device status
                break
            }
        }
    }
    
    private var provisionedWiFi: WifiInfo? {
        didSet {
            passwordRequired = false
            displayedWiFi = provisionedWiFi
            updateButtonState()
        }
    }
    
    var selectedWiFi: WifiInfo? {
        didSet {
            passwordRequired = selectedWiFi?.auth?.isOpen == false
            displayedWiFi = selectedWiFi
            updateButtonState()
        }
    }
    
    @Published(initialValue: false) private (set) var provisioned: Bool
    
    /// The current bluetooth state of the device.
    @Published(initialValue: .disconnected(.byRequest)) fileprivate(set) var peripheralConnectionStatus: PeripheralConnectionStatus
    
    @Published(initialValue: false) private (set) var provisioningInProgress: Bool
    
    @Published(initialValue: nil) var deviceStatus: DeviceStatus? {
        didSet {
            guard let deviceStatus else {
                return
            }
            
            wifiState = deviceStatus.state
            provisionedWiFi = deviceStatus.provisioningInfo
            passwordRequired = false
            provisioned = true
        }
    }
    
    @Published(initialValue: nil) fileprivate(set) var wifiState: ConnectionState? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.provisioningInProgress = self.wifiState?.isInProgress ?? false
                self.updateButtonState()
                
                switch self.wifiState {
                case .connected, .connectionFailed:
                    self.inProgress = false
                default:
                    self.provisioningError = nil
                }
            }
        }
    }
    @Published(initialValue: false) var inProgress: Bool
    @Published(initialValue: nil) private (set) var provisioningError: ReadableError?
    
    @Published(initialValue: UnknownVersion) fileprivate(set) var version: String
    
    @Published(initialValue: false) var showAccessPointList: Bool
    @Published(initialValue: nil) var displayedWiFi: WifiInfo?
    @Published(initialValue: false) private(set) var passwordRequired: Bool
    @Published(initialValue: false) private(set) var showVolatileMemory: Bool
    @Published(initialValue: false) var volatileMemory: Bool
    @Published var password: String = "" {
        didSet {
            updateButtonState()
        }
    }
    @Published var buttonState: ProvisionButtonState = ProvisionButtonState(isEnabled: false, title: "Connect", style: NordicButtonStyle())
    @Published(initialValue: false) var forceShowProvisionInProgress: Bool
    @Published(initialValue: false) var isScanning: Bool
    
    private var cancellable: Set<AnyCancellable> = []
    
    private (set) var provisioner: Provisioner
    let peripheralId: String
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "nordic", category: "DeviceViewModel")
    
    init(peripheralId: String) {
        self.peripheralId = peripheralId
        self.provisioner = Provisioner(deviceId: peripheralId)
        self.provisioner.infoDelegate = self
        self.provisioner.connectionDelegate = self
    }
    
    func connect() {
        switch provisioner.connectionState {
        case .disconnected, .disconnecting:
            provisioner.connect()
            self.peripheralConnectionStatus = .connecting
        case .connected:
            self.peripheralConnectionStatus = .connected
        default:
            break
        }
    }
}

extension DeviceViewModel {
    func readInformation() throws {
        if case .none = self.versionResult {
            try provisioner.readVersion()
        }
        
        if case .none = self.deviceStausResult {
            try provisioner.readDeviceStatus()
        }
    }
    
    func stopScan() async throws {
        /*
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
         */
    }
    
    func startProvision() async throws {
        /*
        Task {
            DispatchQueue.main.async {
                self.wifiState = .disconnected
                self.inProgress = true
            }
        }
        
        let statePublisher = try await provisioner.startProvision(accessPoint: selectedAccessPoint!, passphrase: password.isEmpty ? nil : password, volatileMemory: self.volatileMemory)
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
         */
    }
}

extension DeviceViewModel: ProvisionerConnectionDelegate {
    func connectionStateChanged(_ newState: Provisioner2.Provisioner.ConnectionState) {
        
    }
    
    func deviceConnected() {
        peripheralConnectionStatus = .connected
        
        try? readInformation()
    }
    
    func deviceFailedToConnect(error: Error) {
        peripheralConnectionStatus = .disconnected(.error(error))
    }
    
    func deviceDisconnected(error: Error?) {
        if let error {
            peripheralConnectionStatus = .disconnected(.error(error))
        } else {
            peripheralConnectionStatus = .disconnected(.byRequest)
        }
    }
}

extension DeviceViewModel: ProvisionerInfoDelegate {
    func versionReceived(_ version: Result<Int, ProvisionerInfoError>) {
        versionResult = version
    }
    
    func deviceStatusReceived(_ status: Result<DeviceStatus, ProvisionerError>) {
        deviceStausResult = status
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
        && selectedWiFi != nil
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
                return provisioned ? "Re-Provision" : "Provision"
//            case .connectionFailed(_):
//                return "Try Again"
            case .connected:
                return "Re-provision"
            default:
                return oldTitle
            }
        }()
        
        buttonState.title = title
    }
    
    /*
    private func conventConnectionFailure(_ reason: WiFiStatus.ConnectionFailure) -> ReadableError {
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
     */
}

#if DEBUG

class MockDeviceViewModel: DeviceViewModel {
    init(fakeStatus: ConnectionState) {
        super.init(peripheralId: UUID().uuidString)
    }
    
    override func connect() {
        self.wifiState = .connected
        self.version = "14"
    }
    
    override var displayedWiFi: WifiInfo? {
        get {
            WifiInfo(
                ssid: "Nordic Guest",
                bssid: MACAddress(i: 0xff_02_04_04_33_fa),
                band: .band5Gh,
                channel: 2,
                auth: .wpa2Psk
            )
        }
        set {
            
        }
    }
}
#endif
