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
        @Published var provisioned = false
        @Published var provisionedState = StatusModifier.Status.ready
        @Published var version = UnknownVersion
        @Published var connectionStatus = WiFiConnectionStatus()
        @Published var wifiNetwork = WiFiNetwork()
        @Published var buttonConfiguration = ButtonsConfig()
        
        @Published var showAccessPointList = false
        @Published var showError = false
        
        @Published var peripheralConnectionStatus = PeripheralConnectionStatus.disconnected(.byRequest)
        
        @Published var password = "" {
            didSet {
                buttonConfiguration.enabledProvisionButton = password.count > 6 && passwordRequired
            }
        }
        
        /*
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
         */
        
        var selectedWiFi: WifiInfo? {
            didSet {
                wifiNetwork.ssid = selectedWiFi?.ssid ?? "n/a"
                wifiNetwork.channel = selectedWiFi?.channel
                wifiNetwork.bssid = selectedWiFi?.bssid.description
                wifiNetwork.band = selectedWiFi?.band?.description
                wifiNetwork.security = selectedWiFi?.auth?.description
                
                wifiNetwork.showVolatileMemory = true
                wifiNetwork.showPassword = passwordRequired
                password = ""
                
                buttonConfiguration.enabledProvisionButton = !passwordRequired
                
                updateButtonState()
            }
        }

        var passwordRequired: Bool {
            selectedWiFi?.auth?.isOpen == false
        }
/*
        /// The current bluetooth state of the device.
        

        @Published(initialValue: false) private (set) var provisioningInProgress: Bool

        @Published(initialValue: nil) var deviceStatus: DeviceStatus? {
            didSet {
                guard let deviceStatus else {
                    return
                }

                wifiState = deviceStatus.state
                provisionedWiFi = deviceStatus.provisioningInfo
                passwordRequired = false
                provisioned = deviceStatus.provisioningInfo != nil
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
        */
        var error: ReadableError? {
            didSet {
                if error != nil {
                    self.showError = true
                }
            }
        }
        
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
        
        init(provisioner: Provisioner) {
            self.deviceId = provisioner.deviceId
            self.provisioner = provisioner
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
        try provisioner.readVersion()
        try provisioner.readDeviceStatus()
    }
    
    func startProvision() throws {
        guard let selectedWiFi else {
            return
        }
        
        if passwordRequired {
            guard password.count > 6 else {
                return
            }
        }
        
        setBothButton(enabled: false)
        
        try provisioner.setConfig(wifi: selectedWiFi, passphrase: password, volatileMemory: wifiNetwork.volatileMemory)
    }
    
    func unprovision() throws {
        setBothButton(enabled: false)
        try provisioner.forgetConfig()
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
        switch version {
        case .success(let success):
            self.version = "\(success)"
        case .failure(let error):
            self.error = TitleMessageError(error: error)
            self.version = "Error"
        }
    }
    
    func deviceStatusReceived(_ status: Result<DeviceStatus, ProvisionerError>) {
        switch status {
        case .success(let success):
            if let wifi = success.provisioningInfo {
                provisioned = true
                provisionedState = .done
                buttonConfiguration.showUnsetButton = true
                updateProvisionedComponentVisibility(provisioned: true)
                
                wifiNetwork.ssid = wifi.ssid
                wifiNetwork.channel = wifi.channel
                wifiNetwork.bssid = wifi.bssid.description
                if let band = wifi.band?.description {
                    wifiNetwork.band = band
                }
                
                if let connectinStatus = success.state {
                    self.connectionStatus.status = connectinStatus.description
                    self.connectionStatus.showStatus = true
                    
                    switch success.state {
                    case .connected:
                        self.connectionStatus.statusProgressState = .done
                    case .connectionFailed(_):
                        self.connectionStatus.statusProgressState = .error
                    default:
                        break
                    }
                }
                
                if let ip = success.connectionInfo?.ip?.description {
                    self.connectionStatus.ipAddress = ip
                    self.connectionStatus.showIpAddress = true
                }
                
                updateButtonState()
            } else {
                provisioned = false
                updateProvisionedComponentVisibility(provisioned: false)
                
                updateButtonState()
            }
        case .failure(let failure):
            self.error = TitleMessageError(error: failure)
        }
    }
}

extension DeviceView.ViewModel: ProvisionerDelegate {
    func provisionerDidSetConfig(provisioner: Provisioner2.Provisioner, error: Error?) {
        buttonConfiguration.enabledUnsetButton = true
        if let error {
            self.error = TitleMessageError(error: error)
            buttonConfiguration.enabledProvisionButton = true
        } else {
            password = ""
            
            buttonConfiguration.enabledProvisionButton = false
            buttonConfiguration.showUnsetButton = true
            
            wifiNetwork.showPassword = false
            wifiNetwork.showVolatileMemory = false
            
            self.provisioned = true
            self.provisionedState = .done
            self.connectionStatus.showIpAddress = false
            self.connectionStatus.showStatus = true
            self.connectionStatus.status = ConnectionState.disconnected.description
            self.connectionStatus.statusProgressState = .inProgress
        }
        updateButtonState()
    }
    
    func provisioner(_ provisioner: Provisioner2.Provisioner, didChangeState state: Provisioner2.ConnectionState) {
        connectionStatus.showStatus = true
        connectionStatus.status = state.description
        
        if case .connected = state {
            try? provisioner.readDeviceStatus()
        }
    }
    
    func provisionerDidUnsetConfig(provisioner: Provisioner2.Provisioner, error: Error?) {
        if let error {
            self.error = TitleMessageError(error: error)
        } else {
            provisioned = false
            provisionedState = .ready
            connectionStatus.showStatus = false
            connectionStatus.showIpAddress = false
            connectionStatus.statusProgressState = .ready
            buttonConfiguration.showUnsetButton = false
            
            wifiNetwork = WiFiNetwork()
        }
    }
}

extension DeviceView.ViewModel {
    private func updateProvisionedComponentVisibility(provisioned: Bool) {
        connectionStatus.showStatus = provisioned
        connectionStatus.showIpAddress = provisioned
    }
    
    private func setBothButton(enabled: Bool) {
        buttonConfiguration.enabledProvisionButton = enabled
        buttonConfiguration.enabledUnsetButton = enabled
    }
    
    private func updateButtonState() {
        if provisioned {
            buttonConfiguration.provisionButtonTitle = "Update Configuration"
        } else {
            buttonConfiguration.provisionButtonTitle = "Set Configuration"
        }
        
        
        
        /*
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
         */
    }
}
