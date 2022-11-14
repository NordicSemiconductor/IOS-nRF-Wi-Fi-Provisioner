//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation

open class Provisioner {
    private let internalProvisioner: InternalProvisioner
    
    public init(deviceId: String) {
        self.internalProvisioner = InternalProvisioner(deviceId: deviceId)
    }
    
    open var deviceId: String {
        internalProvisioner.deviceId
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
    
    open func connect() {
        internalProvisioner.connect()
    }

    /// Read the device version
    ///
    /// - Throws: If the version was request but device is not connected, this method throws `DeviceNotConnectedError`
    open func readVersion() throws {
        
    }

    open func readDeviceStatus() throws {
        
    }
}
