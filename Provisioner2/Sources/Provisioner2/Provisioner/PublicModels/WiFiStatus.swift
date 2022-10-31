//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation

public protocol DeviceStatus {
    var state: ConnectionState? { get }
    var provisioningInfo: WifiInfo? { get }
    var connectionInfo: ConnectionInfo? { get }
    var scanInfo: ScanParams? { get }
}

extension Envelope: DeviceStatus where P == Proto.DeviceStatus {
    var provisioningInfo: WifiInfo? {
        model.hasProvisioningInfo ? Envelope<Proto.WifiInfo>(model: model.provisioningInfo) : nil
    }
    
    var state: ConnectionState? {
        model.hasState ? ConnectionState(proto: model.state) : nil
    }
    
    var connectionInfo: ConnectionInfo? {
        model.hasConnectionInfo ? Envelope<Proto.ConnectionInfo>(model: model.connectionInfo) : nil
    }
    
    var scanInfo: ScanParams? {
        model.hasScanInfo ? Envelope<Proto.ScanParams>(model: model.scanInfo) : nil 
    }
}
