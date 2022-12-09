//
//  File.swift
//  
//
//  Created by Nick Kibysh on 11/11/2022.
//

import Foundation

extension DeviceManager {
    /// Bluetooth Connection State.
    public enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }
}
