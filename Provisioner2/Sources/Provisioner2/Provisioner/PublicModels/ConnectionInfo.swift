//
//  File.swift
//  
//
//  Created by Nick Kibysh on 31/10/2022.
//

import Foundation

public protocol ConnectionInfo {
    var ip: IPAddress { get }
}

extension Envelope: ConnectionInfo where P == Proto.ConnectionInfo {
    var ip: IPAddress {
        IPAddress(data: model.ip4Addr)
    }
}
