//
//  File.swift
//  
//
//  Created by Nick Kibysh on 11/10/2022.
//

import Foundation
import Provisioner2

class MockScanDelegate: ScannerDelegate {
    
    var states = [Provisioner2.Scanner.State]()
    var scanResults = [Provisioner2.ScanResult]()
    
    var isScanning: Bool = false
    
    var scanStatusHandler: ((Bool) -> ())?
    var discoveredDevice: ((ScanResult) -> ())?
    var managerStatus: ((Provisioner2.Scanner.State) -> Void)?
    
    func scannerDidUpdateState(_ state: Provisioner2.Scanner.State) {
        managerStatus?(state)
        states.append(state)
    }
    
    func scannerDidDiscover(_ scanResult: Provisioner2.ScanResult) {
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
