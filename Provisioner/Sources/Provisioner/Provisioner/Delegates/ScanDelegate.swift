//
//  File.swift
//  
//
//  Created by Nick Kibysh on 14/11/2022.
//

import Foundation

/// A protocol that defines a delegate for retrieving Wi-Fi scan results.
public protocol ScanDelegate: AnyObject {
    /// Called when the new Wi-Fi scan result is received.
    ///
    /// - parameter wifi: The Wi-Fi Info.
    /// - parameter rssi: The RSSI value. The value is in dBm.
    func deviceManager(_ deviceManager: DeviceManager, discoveredAccessPoint wifi: WifiInfo, rssi: Int?)
    
    /// Notify delegate that scanning for Access Points started
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occurred.
    func deviceManagerDidStartScan(_ deviceManager: DeviceManager, error: Error?)
    
    /// Notify delegate that scanning for Access Points started
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occurred.
    func deviceManagerDidStopScan(_ deviceManager: DeviceManager, error: Error?)
}
