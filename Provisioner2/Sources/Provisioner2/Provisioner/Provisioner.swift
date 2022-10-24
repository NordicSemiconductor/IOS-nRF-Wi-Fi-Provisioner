//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation

public protocol Provisioner {
    var deviceId: String { get }
    var connectionDelegate: ProvisionerConnectionDelegate? { get set }
    
    func connect()
    func readVersion()
    func readWiFiStatus()
    func readProvisioningStatus()
}

public struct ProvisionerFactory {
    static func create(deviceId: String) -> Provisioner & AnyObject {
        InternalProvisioner(deviceId: deviceId)
    }
}
