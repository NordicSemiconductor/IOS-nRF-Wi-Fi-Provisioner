/*
* Copyright (c) 2022, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

/// `DeviceManager` allows you to connect to the device, read the device version and status, 
/// scan for Wi-Fi networks, and provision / unprovision the device.
///
/// In order to have full control over connection and provisioning process, you need to set 
/// ``connectionDelegate``, ``infoDelegate``, ``provisionerScanDelegate`` and ``provisionerDelegate``.
///
/// Before connecting the device, make sure that ``connectionState-swift.property`` is set to ``ConnectionState/connected``.
open class DeviceManager {
    lazy private var internalProvisioner = InternalDeviceManager(deviceId: self.deviceId, provisioner: self)
    
    /// The device identifier.
    public let deviceId: UUID
    
    /// Initialize a new instance of the `DeviceManager`.
    ///
    /// - Remark: See also: ``init(scanResult:)``
    /// - Precondition: `deviceId` should be a valid UUID String, otherwise ``connect()`` method will fail.
    /// - Parameter deviceId: ID of the device. It's equal to the `CBPeripheral`'s identifier
    public init(deviceId: UUID) {
        self.deviceId = deviceId
    }
    
    /// Initialize a new instance of the `DeviceManager`.
    ///
    /// - Remark: See also: ``init(deviceId:)``
    /// - Parameter scanResult: ``ScanResult`` discovered by ``Scanner``
    convenience public init(scanResult: ScanResult) {
        self.init(deviceId: scanResult.id)
    }
    
    /// Bluetooth Connection State.
    ///
    /// This property represents connection to the nRF-7 device (peripheral). Make sure it's 
    /// ``ConnectionState-swift.enum/connected`` before try to communicate with the device.
    ///
    /// - Remark: See also: ``connect()`` and ``ConnectionDelegate/deviceManager(_:changedConnectionState:)``
    open var connectionState: ConnectionState {
        internalProvisioner.connectionState
    }
    
    /// The delegate that you want to receive bluetooth connection events.
    open var connectionDelegate: ConnectionDelegate? {
        get {
            internalProvisioner.connectionDelegate
        }
        set {
            internalProvisioner.connectionDelegate = newValue
        }
    }
    
    /// The delegate object with methods for retrieving device information.
    open var infoDelegate: InfoDelegate? {
        get {
            internalProvisioner.infoDelegate
        }
        set {
            internalProvisioner.infoDelegate = newValue
        }
    }

    /// The object that you want to receive Wi-Fi scan results.
    open var wiFiScanerDelegate: WiFiScanerDelegate? {
        get {
            internalProvisioner.provisionerScanDelegate
        }
        set {
            internalProvisioner.provisionerScanDelegate = newValue
        }
    }

    /// The delegate that you want to receive provisioning events and Wi-Fi connection status.
    open var provisionerDelegate: ProvisionDelegate? {
        get {
            internalProvisioner.provisionerDelegate
        }
        set {
            internalProvisioner.provisionerDelegate = newValue
        }
    }
    
    /// Connect to the device.
    ///
    /// Result of the connection will be delivered to ``ConnectionDelegate/deviceManagerConnectedDevice(_:)`` or ``ConnectionDelegate/deviceManagerDidFailToConnect(_:error:)``.
    ///
    /// ``connectionState-swift.property`` will be updated. Also the new state will be delivered to ``ConnectionDelegate/deviceManager(_:changedConnectionState:)``
    ///
    /// - Remark: See also: ``connectionState-swift.property`` and ``ConnectionDelegate``
    /// - Precondition: Make sure that iOS or MacOS device supports bluetooth and it's turned on and ready to use.
    open func connect() {
        internalProvisioner.connect()
    }
    
    /// Cancel connection.
    ///
    /// The connected device will cancel its connection and the result will be delivered to 
    /// ``ConnectionDelegate/deviceManagerDisconnectedDevice(_:error:)``.
    ///
    /// If there is no connected device, nothing will happen.
    open func disconnect() {
        internalProvisioner.disconnect()
    }

    /// Read the device version.
    ///
    /// The result will be delivered to ``InfoDelegate/versionReceived(_:)``
    /// - Precondition: Make sure that ``connectionState-swift.property`` is 
    ///                 ``ConnectionState-swift.enum/connected`` before calling this method.
    /// - Throws: If the version was request but device is not connected, this method throws ``DeviceNotConnectedError``.
    open func readVersion() throws {
        try internalProvisioner.readVersion()
    }

    /// Read the device status.
    ///
    /// The result of this method is delivered to ``InfoDelegate/deviceStatusReceived(_:)``
    ///
    /// - Precondition: Make sure that ``connectionState-swift.property`` is
    ///                 ``ConnectionState-swift.enum/connected`` before calling this method.
    /// - Throws: If the status was request but device is not connected, this method throws ``DeviceNotConnectedError``.
    open func readDeviceStatus() throws {
        try internalProvisioner.readDeviceStatus()
    }

    /// Start scan for Wi-Fi networks.
    ///
    /// The result of this method is delivered to 
    /// ``WiFiScannerDelegate/deviceManager(_:discoveredAccessPoint:rssi:)``.
    /// Also ``WiFiScannerDelegate/deviceManagerDidStartScan(_:error:)`` will be called.
    ///
    /// - Remark: See also: ``startScan(band:passive:period:groupChannels:)``
    /// - Precondition: Make sure that ``connectionState-swift.property`` is ``ConnectionState-swift.enum/connected`` before calling this method.
    /// - Parameter scanParams: Scan parameters
    /// - Throws: If the scan was request but device is not connected, this method throws ``DeviceNotConnectedError``.
    open func startScan(scanParams: ScanParams = ScanParams()) throws {
        try internalProvisioner.startScan(scanParams: scanParams)
    }

    /// Start scan for Wi-Fi networks
    ///
    /// The result of this method is delivered to 
    /// ``WiFiScannerDelegate/deviceManager(_:discoveredAccessPoint:rssi:)``.
    /// Also ``WiFiScannerDelegate/deviceManagerDidStartScan(_:error:)`` will be called.
    ///
    /// - Precondition: Make sure that ``connectionState-swift.property`` is 
    ///                 ``ConnectionState-swift.enum/connected`` before calling this method.
    ///
    /// - Parameters:
    ///   - band: Band to scan
    ///   - passive: TODO: What is this?
    ///   - period: Period of scan in milliseconds
    ///   - groupChannels: TODO: What is this?
    ///
    /// - Throws: If the scan was request but device is not connected, this method throws ``DeviceNotConnectedError``.
    ///
    /// - Remark: See also: ``startScan(scanParams:)``
    open func startScan(band: ScanParams.Band = .any, passive: Bool = true, period: UInt, groupChannels: UInt) throws {
        let scanParams = ScanParams(band: band, passive: passive, periodMs: period, groupChannels: groupChannels)
        try self.startScan(scanParams: scanParams)
    }
    
    /// Stop scan for Wi-Fi networks.
    ///
    /// ``WiFiScannerDelegate/deviceManagerDidStopScan(_:error:)`` will be called.
    ///
    /// - Precondition: Make sure that ``connectionState-swift.property`` is 
    ///                 ``ConnectionState-swift.enum/connected`` before calling this method.
    ///
    /// - Throws: If the `stopScan` was called but device is not connected, this method throws ``DeviceNotConnectedError``.
    open func stopScan() throws {
        try internalProvisioner.stopScan()
    }
    
    /// Start provisioning.
    ///
    /// Set Wi-Fi configuration to the device. The result of this method is delivered to 
    /// ``ProvisionDelegate/deviceManagerDidSetConfig(_:error:)``.
    /// If the new configuration is set successfully, the device will try to connect to provided Wi-Fi network.
    /// Wi-Fi connection status will be sent to ``ProvisionDelegate/deviceManager(_:didChangeState:)``.
    ///
    /// - Precondition: Make sure that ``connectionState-swift.property`` is 
    ///                 ``ConnectionState-swift.enum/connected`` before calling this method.
    ///
    /// - Remark: See also: ``setConfig(wifi:passphrase:volatileMemory:)``
    /// - Parameters:
    ///   - config: Wi-Fi configuration
    /// - Throws: If the provisioning was request but device is not connected, this method throws ``DeviceNotConnectedError``. You should call ``connect()`` before provisioning.
    open func setConfig(_ config: WifiConfig) throws {
        try internalProvisioner.setConfig(config)
    }
    
    /// Start provisioning.
    ///
    /// Set Wi-Fi configuration to the device. The result of this method is delivered to 
    /// ``ProvisionDelegate/deviceManagerDidSetConfig(_:error:)``.
    /// If the new configuration is set successfully, the device will try to connect to provided Wi-Fi network. 
    /// Wi-Fi connection status will be sent to ``ProvisionDelegate/deviceManager(_:didChangeState:)``.
    ///
    /// - Precondition: Make sure that ``connectionState-swift.property`` is 
    ///                 ``ConnectionState-swift.enum/connected`` before calling this method.
    ///
    /// - Remark: See also: ``setConfig(_:)``
    /// - Parameters:
    ///   - wifi: Wi-Fi network information
    ///   - passphrase: Wi-Fi network passphrase. If the network is open, this parameter should be `nil`.
    ///   - volatileMemory: If `true`, the configuration will be stored in volatile memory and will be lost after reboot.
    /// - Throws: If the provisioning was requested but device is not connected, this method throws ``DeviceNotConnectedError``. You should call ``connect()`` before provisioning.
    open func setConfig(wifi: WifiInfo?, passphrase: String?, volatileMemory: Bool?) throws {
        let config = WifiConfig(wifi: wifi, passphrase: passphrase, volatileMemory: volatileMemory)
        try self.setConfig(config)
    }

    /// Forget the Wi-Fi configuration.
    ///
    /// The result of this method is delivered to ``ProvisionDelegate/deviceManagerDidForgetConfig(_:error:)``.
    ///
    /// - Precondition: Make sure that ``connectionState-swift.property`` is 
    ///                 ``ConnectionState-swift.enum/connected`` before calling this method.
    ///
    /// - Throws: If the unprovisioning was requested but device is not connected, this method throws ``DeviceNotConnectedError``.
    open func forgetConfig() throws {
        try internalProvisioner.forgetConfig()
    }
}
