//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation

public protocol Provisioner {
    var deviceId: String { get }
    var connectionDelegate: ProvisionerConnectionDelegate? { get set }
    var infoDelegate: ProvisionerInfoDelegate? { get set }
    
    func connect()

    /// Read the device version
    ///
    /// - Throws: If the version was request but device is not connected, this method throws `DeviceNotConnectedError`
    func readVersion() throws

    func readDeviceStatus() throws
}

public struct ProvisionerFactory {
    public static func create(deviceId: String) -> Provisioner & AnyObject {
        InternalProvisioner(deviceId: deviceId)
    }
}
