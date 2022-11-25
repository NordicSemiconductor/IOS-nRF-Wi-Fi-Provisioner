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
    var selectedWiFi: WifiInfo? { get set }
    var showAccessPointList: Bool { get set }
}

private let UnknownVersion = "Unknown"

extension DeviceView {
    class ViewModel: ObservableObject, AccessPointSelection {
        private var versionResult: Swift.Result<Int, ProvisionerInfoError>? {
            didSet {
                guard let versionResult else {
                    return
                }

                switch versionResult {
                case .success(let success):
                    self.version = "\(success)"
                case .failure:
                    self.version = "Error"
                }
            }
        }

        private var deviceStausResult: Swift.Result<DeviceStatus, ProvisionerError>? {
            didSet {
                guard let deviceStausResult else {
                    return
                }

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
                showFooter = false
                showVolatileMemory = true
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
                    guard let `self` = self else {
                        return
                    }
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
        @Published(initialValue: true) private(set) var showFooter: Bool
        @Published(initialValue: false) private(set) var showVolatileMemory: Bool
        @Published(initialValue: false) var volatileMemory: Bool
        @Published var password: String = "" {
            didSet {
                updateButtonState()
            }
        }
        private var forceDisableButton = false
        @Published var buttonState: ProvisionButtonState = ProvisionButtonState(isEnabled: false, title: "Connect", style: NordicButtonStyle())
        @Published(initialValue: false) var forceShowProvisionInProgress: Bool
        @Published(initialValue: false) var isScanning: Bool

        private var cancellable: Set<AnyCancellable> = []

        let provisioner: Provisioner
        let deviceId: String
        
        init(deviceId: String) {
            self.deviceId = deviceId
            self.provisioner = Provisioner(deviceId: deviceId)
            self.provisioner.infoDelegate = self
            self.provisioner.connectionDelegate = self
            self.provisioner.provisionerDelegate = self 
        }

        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "nordic", category: "DeviceViewModel")

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
}

extension DeviceView.ViewModel {
    func readInformation() throws {
        if case .none = self.versionResult {
            try provisioner.readVersion()
        }
        
        if case .none = self.deviceStausResult {
            try provisioner.readDeviceStatus()
        }
    }
    
    func startProvision() throws {
        guard let selectedWiFi else {
            return
        }
        
        if passwordRequired {
            guard password.count >= 6 else {
                return
            }
        }
        
        forceDisableButton = true
        updateButtonState()
        
        try provisioner.setConfig(wifi: selectedWiFi, passphrase: password, volatileMemory: volatileMemory)
    }
}

extension DeviceView.ViewModel: ProvisionerConnectionDelegate {
    func provisionerDidFailToConnect(_ provisioner: Provisioner2.Provisioner, error: Error) {
        peripheralConnectionStatus = .disconnected(.error(error))
    }
    
    func provisioner(_ provisioner: Provisioner, changedConnectionState newState: Provisioner.ConnectionState) {
        
    }
    
    func provisionerConnectedDevice(_ provisioner: Provisioner) {
        peripheralConnectionStatus = .connected
        
        try? readInformation()
    }
    
    func provisionerDisconnectedDevice(_ provisioner: Provisioner, error: Error?) {
        if let error {
            peripheralConnectionStatus = .disconnected(.error(error))
        } else {
            peripheralConnectionStatus = .disconnected(.byRequest)
        }
    }
}

extension DeviceView.ViewModel: ProvisionerInfoDelegate {
    func versionReceived(_ version: Result<Int, ProvisionerInfoError>) {
        versionResult = version
    }
    
    func deviceStatusReceived(_ status: Result<DeviceStatus, ProvisionerError>) {
        deviceStausResult = status
    }
}

extension DeviceView.ViewModel: ProvisionerDelegate {
    func provisionerDidSetConfig(provisioner: Provisioner2.Provisioner, error: Error?) {
        provisioned = true
        
        updateButtonState()
    }
    
    func provisioner(_ provisioner: Provisioner2.Provisioner, didChangeState state: Provisioner2.ConnectionState) {
        switch state {
        case .connected, .connectionFailed(_):
            forceDisableButton = false
        default:
            break 
        }
        wifiState = state
    }
    
    func provisionerDidUnsetConfig(provisioner: Provisioner2.Provisioner, error: Error?) {
        
    }
}

extension DeviceView.ViewModel {
    
    private func rethrowError(_ error: ReadableError) throws -> Never {
        DispatchQueue.main.async {
            // TODO: Show error placeholder
        }
        throw error
    }
    
    private func updateButtonState() {
        let enabled = !forceDisableButton
        && wifiState?.isInProgress != true
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
class MockDeviceViewModel: DeviceView.ViewModel {
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
