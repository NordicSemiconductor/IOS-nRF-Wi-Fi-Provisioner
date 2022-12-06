//
// Created by Nick Kibysh on 18/11/2022.
//

import Foundation

public protocol ProvisionDelegate: AnyObject {
    /// Tells the delegate that the new Wi-Fi configuration was sent to the device.
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occured.
    func deviceManagerDidSetConfig(_ deviceManager: DeviceManager, error: Error?)

    /// Tells the delegate that the new Wi-Fi connection status received.
    ///
    /// - Parameters:
    ///   - state: New Wi-Fi connection state
    func deviceManager(_ deviceManager: DeviceManager, didChangeState state: ConnectionState)

    /// Tells the delegate that the Wi-Fi configuration was erased from the device.
    ///
    /// - Parameters:
    ///   - error: Error that caused the failure. `nil` if no error occured.
    func deviceManagerDidForgetConfig(_ deviceManager: DeviceManager, error: Error?)
}
