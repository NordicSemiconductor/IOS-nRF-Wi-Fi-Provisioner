//
// Created by Nick Kibysh on 07/10/2022.
//

import Foundation

public protocol ScannerDelegate: AnyObject {
    func scannerDidUpdateState(_ state: Scanner.State)
    func scannerDidDiscover(_ scanResult: ScanResult)
    func scannerStartedScanning()
    func scannerStoppedScanning()
}
