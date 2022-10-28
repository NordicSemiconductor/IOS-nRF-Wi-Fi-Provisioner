//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation

public protocol DeviceStatus {
//    var state: ConnectionState? { get }
    var provisioningInfo: WifiInfo? { get }
//    var connectionInfo: ConnectionInfo? { get }
//    var scanInfo: ScanParams? { get }
    
}

extension Envelope: DeviceStatus where P == Proto.DeviceStatus {
    var provisioningInfo: WifiInfo? {
        model.hasProvisioningInfo ? Envelope<Proto.WifiInfo>(model: model.provisioningInfo) : nil
    }
    
    
}
