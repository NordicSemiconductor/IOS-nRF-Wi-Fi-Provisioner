//
//  ProvisionerConnectionDelegate.swift
//  
//
//  Created by Nick Kibysh on 17/10/2022.
//

import Foundation

/// A protocol that defines a delegate for Connection flow
public protocol ProvisionerConnectionDelegate: AnyObject {
    /// Tells the delegate that the provisioner has connected to the device
    ///
    func provisionerConnectedDevice(_ provisioner: DeviceManager)

    /// Tells the delegate that the provisioner was not able to connect to the device
    ///
    /// - Parameter error: Error that caused the connection failure
    func provisionerDidFailToConnect(_ provisioner: DeviceManager, error: Error)

    /// Tells the delegate that the provisioner has disconnected from the device
    ///
    /// - Parameter error: If disconnected due to an issue, this parameter contains the error
    func provisionerDisconnectedDevice(_ provisioner: DeviceManager, error: Error?)
    
    /// Tells the delegate that the provisioner changed its connection state
    ///
    /// - Parameter newState: New Connection State
    func provisioner(_ provisioner: DeviceManager, changedConnectionState newState: DeviceManager.ConnectionState)
}
