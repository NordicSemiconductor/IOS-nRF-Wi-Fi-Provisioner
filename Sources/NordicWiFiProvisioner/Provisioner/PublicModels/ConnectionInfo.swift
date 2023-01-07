//
//  File.swift
//  
//
//  Created by Nick Kibysh on 31/10/2022.
//

import Foundation

/// A struct that contains ip address of the device.
public struct ConnectionInfo {
    /// IP address of the device.
    public var ip: IPAddress?
    
    public init(ip: IPAddress? = nil) {
        self.ip = ip
    }
}

extension ConnectionInfo: ProtoConvertible {
    init(proto: Proto.ConnectionInfo) {
        self.ip = proto.hasIp4Addr ? IPAddress(data: proto.ip4Addr) : nil
    }
    
    var proto: Proto.ConnectionInfo {
        var connectionInfo = Proto.ConnectionInfo()
        self.ip.map { connectionInfo.ip4Addr = $0.data }
        return connectionInfo
    }
}
