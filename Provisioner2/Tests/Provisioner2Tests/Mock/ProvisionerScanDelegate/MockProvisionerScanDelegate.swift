//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/11/2022.
//

import Foundation
import CoreBluetoothMock
@testable import Provisioner2

class MockProvisionerScanDelegate: ProvisionerScanDelegate {
    func pravisionerDidStartScan(_ provisioner: Provisioner2.Provisioner, error: Error?) {
        if let error {
            self.startScanError = error
        } else {
            isScanning = true
        }
    }
    
    func pravisionerDidStopScan(_ provisioner: Provisioner2.Provisioner, error: Error?) {
        if let error {
            self.stopScanError = error
        } else {
            isScanning = false 
        }
    }
    
    func provisioner(_ provisioner: Provisioner2.Provisioner, discoveredAccessPoint wifi: Provisioner2.WifiInfo, rssi: Int?) {
        scanresults.append(ScanResult(wifi: wifi, rssi: rssi))
    }
    
    struct ScanResult {
        let wifi: WifiInfo
        let rssi: Int?
    }
    
    var scanresults: [ScanResult] = []
    
    var isScanning: Bool?
    var startScanError: Error?
    var stopScanError: Error?
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

class FailedStartStopScan: ProvMocScannerDelegate {
    override func startScan(_ peripheral: CBMPeripheralSpec) throws -> Result<Void, Error> {
        let response = self.response(status: .internalError, requestCode: .startScan)
        peripheral.simulateValueUpdate(response, for: .controlPoint)
        
        return Swift.Result.success(())
    }
    
    override func stopScan(_ peripheral: CBMPeripheralSpec) throws -> Result<Void, Error> {
        let response = self.response(status: .internalError, requestCode: .stopScan)
        peripheral.simulateValueUpdate(response, for: .controlPoint)
        
        return Swift.Result.success(())
    }
}
