//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation

public struct DeviceStatus {
    public var state: ConnectionState?
    public var provisioningInfo: WifiInfo?
    public var connectionInfo: ConnectionInfo?
    public var scanInfo: ScanParams?
}

extension DeviceStatus: ProtoConvertible {
    init(proto: Proto.DeviceStatus) {
        self.state = proto.hasState ? ConnectionState(proto: proto.state) : nil
        self.provisioningInfo = proto.hasProvisioningInfo ? WifiInfo(proto: proto.provisioningInfo) : nil
        self.connectionInfo = proto.hasProvisioningInfo ? ConnectionInfo(proto: proto.connectionInfo) : nil
        self.scanInfo = proto.hasScanInfo ? ScanParams(proto: proto.scanInfo) : nil
    }
    
    var proto: Proto.DeviceStatus {
        var proto = Proto.DeviceStatus()
        self.state.map { proto.state = $0.proto }
        self.provisioningInfo.map { proto.provisioningInfo = $0.proto }
        self.connectionInfo.map { proto.connectionInfo = $0.proto }
        self.scanInfo.map { proto.scanInfo = $0.proto }
        return proto
    }
}
