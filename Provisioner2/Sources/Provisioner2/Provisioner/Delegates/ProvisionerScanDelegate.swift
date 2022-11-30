//
//  File.swift
//  
//
//  Created by Nick Kibysh on 14/11/2022.
//

import Foundation

/// A protocol that defines a delegate for retrieving Wi-Fi scan results.
public protocol ProvisionerScanDelegate: AnyObject {
    /// Called when the new Wi-Fi scan result is received.
    ///
    /// - parameter wifi: The Wi-Fi Info.
    /// - parameter rssi: The RSSI value. The value is in dBm.
    func provisioner(_ provisioner: DeviceManager, discoveredAccessPoint wifi: WifiInfo, rssi: Int?)
    
    /// Notify delegate that scanning for Access Points started
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occured.
    func pravisionerDidStartScan(_ provisioner: DeviceManager, error: Error?)
    
    /// Notify delegate that scanning for Access Points started
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occured.
    func pravisionerDidStopScan(_ provisioner: DeviceManager, error: Error?)
}
