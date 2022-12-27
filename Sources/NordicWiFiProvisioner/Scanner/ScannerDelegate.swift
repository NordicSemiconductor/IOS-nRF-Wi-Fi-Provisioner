//
// Created by Nick Kibysh on 07/10/2022.
//

import Foundation

/// The delegate that you want to receive scan events and results.
public protocol ScannerDelegate: AnyObject {
    /// Called when bluetooth state changes.
    func scannerDidUpdateState(_ state: Scanner.State)

    /// Called when new scan result is received.
    ///
    /// - parameter scanResult: The scan result.
    func scannerDidDiscover(_ scanResult: ScanResult)

    /// Called when scanning for devices started.
    func scannerStartedScanning()

    /// Called when scanning for devices stopped.
    func scannerStoppedScanning()
}
