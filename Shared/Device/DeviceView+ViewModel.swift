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
import NordicWiFiProvisioner

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
        @Published var infoFooter = ""
        
        @Published var password = "" {
            didSet {
                buttonConfiguration.enabledProvisionButton = password.count > 6 && passwordRequired
            }
        }
        
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
                infoFooter = ""
                
                buttonConfiguration.enabledProvisionButton = !passwordRequired
                
                updateButtonState()
            }
        }

        var passwordRequired: Bool {
            selectedWiFi?.auth?.isOpen == false
        }

        var error: ReadableError? {
            didSet {
                if error != nil {
                    self.showError = true
                }
            }
        }
        
        private var cancellable: Set<AnyCancellable> = []

        let provisioner: DeviceManager
        let deviceId: String
        
        init(deviceId: String) {
            self.deviceId = deviceId
            self.provisioner = DeviceManager(deviceId: deviceId)
            self.provisioner.infoDelegate = self
            self.provisioner.connectionDelegate = self
            self.provisioner.provisionerDelegate = self 
        }
        
        init(provisioner: DeviceManager) {
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

extension DeviceView.ViewModel: ConnectionDelegate {
    func deviceManagerDidFailToConnect(_ provisioner: NordicWiFiProvisioner.DeviceManager, error: Error) {
        peripheralConnectionStatus = .disconnected(.error(error))
    }
    
    func deviceManager(_ provisioner: DeviceManager, changedConnectionState newState: DeviceManager.ConnectionState) {
        
    }
    
    func deviceManagerConnectedDevice(_ provisioner: DeviceManager) {
        peripheralConnectionStatus = .connected
        
        try? readInformation()
    }
    
    func deviceManagerDisconnectedDevice(_ provisioner: DeviceManager, error: Error?) {
        if let error {
            peripheralConnectionStatus = .disconnected(.error(error))
        } else {
            peripheralConnectionStatus = .disconnected(.byRequest)
        }
    }
}

extension DeviceView.ViewModel: InfoDelegate {
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
                
                infoFooter = NSLocalizedString("PROVISIONED_DEVICE_FOOTER", comment: "") // "PROVISIONED_DEVICE_FOOTER"
            } else {
                provisioned = false
                updateProvisionedComponentVisibility(provisioned: false)
                
                updateButtonState()
                
                infoFooter = NSLocalizedString("WIFI_NOT_PROVISIONED_FOOTER", comment: "")
            }
        case .failure(let failure):
            self.error = TitleMessageError(error: failure)
        }
    }
}

extension DeviceView.ViewModel: ProvisionDelegate {
    func deviceManagerDidSetConfig(_ deviceManager: NordicWiFiProvisioner.DeviceManager, error: Error?) {
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
    
    func deviceManager(_ provisioner: NordicWiFiProvisioner.DeviceManager, didChangeState state: NordicWiFiProvisioner.ConnectionState) {
        connectionStatus.showStatus = true
        connectionStatus.status = state.description
        
        if case .connected = state {
            try? provisioner.readDeviceStatus()
        }
    }
    
    func deviceManagerDidForgetConfig(_ deviceManager: DeviceManager, error: Error?) {
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
            
            infoFooter = NSLocalizedString("WIFI_NOT_PROVISIONED_FOOTER", comment: "")
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
    }
}
