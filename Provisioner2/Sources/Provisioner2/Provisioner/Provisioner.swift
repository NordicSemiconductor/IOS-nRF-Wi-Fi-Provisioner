//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation

open class Provisioner {
    lazy private var internalProvisioner = InternalProvisioner(deviceId: self.deviceId, provisioner: self)
    
    public let deviceId: String
    
    public init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    open var connectionState: ConnectionState {
        internalProvisioner.connectionState
    }
    
    open var connectionDelegate: ProvisionerConnectionDelegate? {
        get {
            internalProvisioner.connectionDelegate
        }
        set {
            internalProvisioner.connectionDelegate = newValue
        }
    }
    
    open var infoDelegate: ProvisionerInfoDelegate? {
        get {
            internalProvisioner.infoDelegate
        }
        set {
            internalProvisioner.infoDelegate = newValue
        }
    }

    open var provisionerScanDelegate: ProvisionerScanDelegate? {
        get {
            internalProvisioner.provisionerScanDelegate
        }
        set {
            internalProvisioner.provisionerScanDelegate = newValue
        }
    }

    open var provisionerDelegate: ProvisionerDelegate? {
        get {
            internalProvisioner.provisionerDelegate
        }
        set {
            internalProvisioner.provisionerDelegate = newValue
        }
    }
    
    open func connect() {
        internalProvisioner.connect()
    }

    /// Read the device version
    /// The result will be delivered to `infoDelegate.deviceVersionDidUpdate`
    ///
    /// - Throws: If the version was request but device is not connected, this method throws `DeviceNotConnectedError`
    open func readVersion() throws {
        try internalProvisioner.readVersion()
    }

    /// Read the device status
    /// The result of this method is delivered to `infoDelegate.deviceStatusDidUpdate`
    ///
    /// - Throws: If the status was request but device is not connected, this method throws `DeviceNotConnectedError`
    open func readDeviceStatus() throws {
        try internalProvisioner.readDeviceStatus()
    }

    /// Start scan for Wi-Fi networks
    ///
    /// - Parameter scanParams: Scan parameters
    /// - Throws: If the scan was request but device is not connected, this method throws `DeviceNotConnectedError`
    open func startScan(scanParams: ScanParams) throws {
        try internalProvisioner.startScan(scanParams: scanParams)
    }
    
    open func stopScan() throws {
        try internalProvisioner.stopScan()
    }

    /// Start scan for Wi-Fi networks
    ///
    /// - Parameters:
    ///   - band: Band to scan
    ///   - passive: TODO: What is this?
    ///   - period: Period of scan in milliseconds
    ///   - groupChannels: TODO: What is this?
    /// - Throws: If the scan was request but device is not connected, this method throws `DeviceNotConnectedError`
    open func startScan(band: ScanParams.Band = .any, passive: Bool = true, period: UInt, groupChannels: UInt) throws {
        let scanParams = ScanParams(band: band, passive: passive, periodMs: period, groupChannels: groupChannels)
        try self.startScan(scanParams: scanParams)
    }
    
    open func setConfig(_ config: WifiConfig) throws {
        try internalProvisioner.setConfig(config)
    }
    
    open func setConfig(wifi: WifiInfo?, passphrase: String?, volatileMemory: Bool?) throws {
        let config = WifiConfig(wifi: wifi, passphrase: passphrase, volatileMemory: volatileMemory)
        try self.setConfig(config)
    }
}
