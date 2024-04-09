//
//  DeviceViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import Foundation
import Combine
import os
import NordicWiFiProvisioner_BLE

private let UnknownVersion = "Unknown"

extension DeviceView {
    
    class ViewModel: ObservableObject {
        @Published var provisioned = false
        @Published var provisionedState = StatusModifier.Status.ready
        @Published var version = UnknownVersion
        @Published var connectionStatus = WiFiConnectionStatus()
        @Published var showPassword = false
        @Published var showVolatileMemory = false
        @Published var volatileMemory = false
        @Published var buttonConfiguration = ButtonsConfig()
        
        @Published var showAccessPointList = false
        @Published var showError = false
        @Published(initialValue: []) var accessPoints: [WifiScanResult]
        
        @Published var peripheralConnectionStatus = PeripheralConnectionStatus.disconnected(.byRequest)
        @Published var infoFooter = ""
        
        @Published var password = "" {
            didSet {
                buttonConfiguration.enabledProvisionButton = password.count > 6 && passwordRequired
            }
        }
        
        @Published(initialValue: nil) var wifiNetwork: WifiInfo? {
            didSet {
                password = ""
                infoFooter = ""
                buttonConfiguration.enabledProvisionButton = !passwordRequired
                updateButtonState()
            }
        }

        var passwordRequired: Bool {
            wifiNetwork?.auth?.isOpen == false
        }

        var error: ReadableError? {
            didSet {
                if error != nil {
                    showError = true
                }
            }
        }

        let provisioner: DeviceManager
        let deviceId: String
        
        init(deviceId: String) {
            self.deviceId = deviceId
            self.provisioner = DeviceManager(deviceId: UUID(uuidString: deviceId)!)
            self.provisioner.infoDelegate = self
            self.provisioner.connectionDelegate = self
            self.provisioner.provisionerDelegate = self
            self.provisioner.wiFiScanerDelegate = self
        }
        
        init(provisioner: DeviceManager) {
            self.deviceId = provisioner.deviceId.uuidString
            self.provisioner = provisioner
            self.provisioner.infoDelegate = self
            self.provisioner.connectionDelegate = self
            self.provisioner.provisionerDelegate = self
            self.provisioner.wiFiScanerDelegate = self
        }

        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "nordic", category: "DeviceViewModel")
    }
}

// MARK: - API

extension DeviceView.ViewModel {
    
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
    
    func startScanning() {
        do {
            try provisioner.startScan(scanParams: ScanParams())
        } catch {
            self.error = TitleMessageError(error)
        }
    }
    
    func stopScanning() {
        do {
            try provisioner.stopScan()
        } catch {
            self.error = TitleMessageError(error)
        }
    }
    
    func readInformation() throws {
        try provisioner.readVersion()
        try provisioner.readDeviceStatus()
    }
    
    func startProvision() throws {
        guard let wifiNetwork else {
            return
        }
        
        if passwordRequired {
            guard password.count > 6 else {
                return
            }
        }
        
        setBothButton(enabled: false)
        
        try provisioner.setConfig(wifi: wifiNetwork, passphrase: password, volatileMemory: volatileMemory)
    }
    
    func unprovision() throws {
        setBothButton(enabled: false)
        try provisioner.forgetConfig()
    }
}

// MARK: - ConnectionDelegate

extension DeviceView.ViewModel: ConnectionDelegate {
    
    func deviceManagerDidFailToConnect(_ provisioner: NordicWiFiProvisioner_BLE.DeviceManager, error: Error) {
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

// MARK: - InfoDelegate

extension DeviceView.ViewModel: InfoDelegate {
    func versionReceived(_ version: Result<Int, ProvisionerInfoError>) {
        switch version {
        case .success(let success):
            self.version = "\(success)"
        case .failure(let error):
            self.error = TitleMessageError(error)
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
                
                wifiNetwork = wifi
                
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
        case .failure(let cause):
            self.error = TitleMessageError(cause)
        }
    }
}

// MARK: - WiFiScanerDelegate

extension DeviceView.ViewModel: WiFiScanerDelegate {
    
    func deviceManager(_ provisioner: NordicWiFiProvisioner_BLE.DeviceManager, discoveredAccessPoint wifi: NordicWiFiProvisioner_BLE.WifiInfo, rssi: Int?) {
        let scanResult = WifiScanResult(wifi: wifi, rssi: rssi)
        accessPoints.append(scanResult)
    }
    
    func deviceManagerDidStartScan(_ provisioner: NordicWiFiProvisioner_BLE.DeviceManager, error: Error?) {
        if let error {
            self.error = TitleMessageError(error)
        }
    }
    
    func deviceManagerDidStopScan(_ provisioner: NordicWiFiProvisioner_BLE.DeviceManager, error: Error?) {
        if let error {
            self.error = TitleMessageError(error)
        }
    }
}

// MARK: - ProvisionDelegate

extension DeviceView.ViewModel: ProvisionDelegate {
    
    func deviceManagerDidSetConfig(_ deviceManager: NordicWiFiProvisioner_BLE.DeviceManager, error: Error?) {
        buttonConfiguration.enabledUnsetButton = true
        if let error {
            self.error = TitleMessageError(error)
            buttonConfiguration.enabledProvisionButton = true
        } else {
            password = ""
            
            buttonConfiguration.enabledProvisionButton = false
            buttonConfiguration.showUnsetButton = true
            
            self.provisioned = true
            self.provisionedState = .done
            self.connectionStatus.showIpAddress = false
            self.connectionStatus.showStatus = true
            self.connectionStatus.status = ConnectionState.disconnected.description
            self.connectionStatus.statusProgressState = .inProgress
            self.showPassword = false
            self.showVolatileMemory = false
        }
        updateButtonState()
    }
    
    func deviceManager(_ provisioner: NordicWiFiProvisioner_BLE.DeviceManager, didChangeState state: NordicWiFiProvisioner_BLE.ConnectionState) {
        connectionStatus.showStatus = true
        connectionStatus.status = state.description
        
        if case .connected = state {
            try? provisioner.readDeviceStatus()
        }
    }
    
    func deviceManagerDidForgetConfig(_ deviceManager: DeviceManager, error: Error?) {
        if let error {
            self.error = TitleMessageError(error)
        } else {
            provisioned = false
            provisionedState = .ready
            connectionStatus.showStatus = false
            connectionStatus.showIpAddress = false
            connectionStatus.statusProgressState = .ready
            buttonConfiguration.showUnsetButton = false
            wifiNetwork = nil
            
            infoFooter = NSLocalizedString("WIFI_NOT_PROVISIONED_FOOTER", comment: "")
        }
    }
}

// MARK: - Private

private extension DeviceView.ViewModel {
    
    func updateProvisionedComponentVisibility(provisioned: Bool) {
        connectionStatus.showStatus = provisioned
        connectionStatus.showIpAddress = provisioned
    }
    
    func setBothButton(enabled: Bool) {
        buttonConfiguration.enabledProvisionButton = enabled
        buttonConfiguration.enabledUnsetButton = enabled
    }
    
    func updateButtonState() {
        if provisioned {
            buttonConfiguration.provisionButtonTitle = "Update Configuration"
        } else {
            buttonConfiguration.provisionButtonTitle = "Set Configuration"
        }
    }
}
