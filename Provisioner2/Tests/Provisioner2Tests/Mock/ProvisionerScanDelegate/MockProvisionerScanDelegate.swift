//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/11/2022.
//

import Foundation
@testable import Provisioner2

class MockProvisionerScanDelegate: ProvisionerScanDelegate {
    struct ScanResult {
        let wifi: WifiInfo
        let rssi: Int?
    }
    
    var scanresults: [ScanResult] = []
    
    func accessPointDiscovered(_ wifi: Provisioner2.WifiInfo, rssi: Int?) {
        scanresults.append(ScanResult(wifi: wifi, rssi: rssi))
    }
}

// MARK: - CBM Delegate

class ProvMocScannerDelegate: WifiDeviceDelegate {
    override func accessPoints() throws -> [Proto.Result] {
        var aps: [Proto.Result] = []
        
        // This should be ignored by scanner
        var connectionResult = Proto.Result()
        connectionResult.state = .connected
        aps.append(connectionResult)
        
        var connectionFailure = Proto.Result()
        connectionFailure.reason = .authError
        aps.append(connectionFailure)
        
        var withoutRSSI = Proto.Result()
        withoutRSSI.scanRecord = Proto.ScanRecord.badSR2
        aps.append(withoutRSSI)
        
        var result0 = Proto.Result()
        result0.scanRecord = Proto.ScanRecord.badSR1
        aps.append(result0)
        
        var result1 = Proto.Result()
        result1.scanRecord = Proto.ScanRecord.sr1
        aps.append(result1)
        
        var result2 = Proto.Result()
        result2.scanRecord = Proto.ScanRecord.sr2
        aps.append(result2)
        
        return aps
    }
}
