//
//  ProvisionerInfoDelegate.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import Foundation

/// A protocol that defines a delegate for reading device info
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
