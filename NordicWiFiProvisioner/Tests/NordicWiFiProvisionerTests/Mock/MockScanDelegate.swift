//
//  File.swift
//  
//
//  Created by Nick Kibysh on 11/10/2022.
//

import Foundation
import NordicWiFiProvisioner

class MockScanDelegate: ScannerDelegate {
    
    var states = [NordicWiFiProvisioner.Scanner.State]()
    var scanResults = [NordicWiFiProvisioner.ScanResult]()
    
    var isScanning: Bool = false
    
    var scanStatusHandler: ((Bool) -> ())?
    var discoveredDevice: ((ScanResult) -> ())?
    var managerStatus: ((NordicWiFiProvisioner.Scanner.State) -> Void)?
    
    func scannerDidUpdateState(_ state: NordicWiFiProvisioner.Scanner.State) {
        managerStatus?(state)
        states.append(state)
    }
    
    func scannerDidDiscover(_ scanResult: NordicWiFiProvisioner.ScanResult) {
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
