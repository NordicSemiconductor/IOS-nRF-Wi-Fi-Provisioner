//
//  File.swift
//  
//
//  Created by Nick Kibysh on 11/10/2022.
//

import Foundation
import Provisioner

class MockScanDelegate: ScannerDelegate {
    
    var states = [Provisioner.Scanner.State]()
    var scanResults = [Provisioner.ScanResult]()
    
    var isScanning: Bool = false
    
    var scanStatusHandler: ((Bool) -> ())?
    var discoveredDevice: ((ScanResult) -> ())?
    var managerStatus: ((Provisioner.Scanner.State) -> Void)?
    
    func scannerDidUpdateState(_ state: Provisioner.Scanner.State) {
        managerStatus?(state)
        states.append(state)
    }
    
    func scannerDidDiscover(_ scanResult: Provisioner.ScanResult) {
        scanResults.append(scanResult)
        discoveredDevice?(scanResult)
    }
    
    func scannerStartedScanning() {
        scanStatusHandler?(true)
        isScanning = true
    }
    
    func scannerStoppedScanning() {
        scanStatusHandler?(false)
        isScanning = false 
    }
}
