//
// Created by Nick Kibysh on 18/11/2022.
//

import Foundation

public protocol ProvisionerDelegate: AnyObject {
    /// Tells the delegate that the new Wi-Fi configuration was sent to the device.
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occured.
    func provisionerDidSetConfig(provisioner: Provisioner, error: Error?)

    /// Tells the delegate that the new Wi-Fi connection status received.
    ///
    /// - Parameters:
    ///   - state: New Wi-Fi connection state
    func provisioner(_ provisioner: Provisioner, didChangeState state: ConnectionState)

    /// Tells the delegate that the Wi-Fi configuration was erased from the device.
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occured.
    func provisionerDidUnsetConfig(provisioner: Provisioner, error: Error?)
}
