//
//  File.swift
//  
//
//  Created by Nick Kibysh on 17/10/2022.
//

import Foundation

/// A protocol that defines a delegate for Connection flow
public protocol ProvisionerConnectionDelegate: AnyObject {
    /// Tells the delegate that the provisioner has connected to the device
    ///
    /// - Parameter id: Device identifier (UUID String)
    func deviceConnected()

    /// Tells the delegate that the provisioner was not able to connect to the device
    ///
    /// - Parameter error: Error that caused the connection failure
    func deviceFailedToConnect(error: Error)

    /// Tells the delegate that the provisioner has disconnected from the device
    ///
    /// - Parameter error: If disconnected due to an issue, this parameter contains the error
    func deviceDisconnected(error: Error?)
}

public protocol ProvisionerInfoDelegate: AnyObject {
    /// Tells the delegate that the version of the device is received
    ///
    /// - Parameter version: Version of the device // TODO: Check the correctness of the parameter
    func versionReceived(_ version: Int)

    /// Tells the delegate that WiFi status changed
    ///
    /// - Parameter status: New WiFi status
    func wifiStatusReceived(_ status: WiFiStatus)
}
