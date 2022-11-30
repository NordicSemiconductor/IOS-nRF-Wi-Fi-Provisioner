//
//  ProvisionerScannTests.swift
//  
//
//  Created by Nick Kibysh on 15/11/2022.
//

import XCTest
import CoreBluetoothMock
@testable import Provisioner

final class ProvisionerScannTests: XCTestCase {
    
    var scanDelegate: MockProvisionerScanDelegate!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals([
            noServiceDevice, badVersionDataDevice, wifiDevice,
            invalidArgumentDevice, invalidProtoDevice, internalErrorDevice,
            scanResultDevice, failedScanResultDevice
        ])
        CBMCentralManagerMock.simulatePowerOn()
        
        scanDelegate = MockProvisionerScanDelegate()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        CBMCentralManagerMock.tearDownSimulation()
    }
    
    func testNotConnectedError() throws {
        let provisioner = DeviceManager(deviceId: scanResultDevice.identifier.uuidString)
        provisioner.provisionerScanDelegate = scanDelegate
        
        XCTAssertThrowsError(try provisioner.startScan(scanParams: ScanParams()))
    }
    
    func testScan() throws {
        let provisioner = DeviceManager(deviceId: scanResultDevice.identifier.uuidString)
        provisioner.provisionerScanDelegate = scanDelegate
        provisioner.connect()
        
        wait(1)
        
        XCTAssertNoThrow(try provisioner.startScan(scanParams: ScanParams()))
        
        wait(2)
        
        XCTAssertEqual(scanDelegate.isScanning, true)
        XCTAssertEqual(scanDelegate.scanresults.count, 4)
        XCTAssertEqual(scanDelegate.scanresults[3].wifi.ssid, WifiInfo.wifi2.ssid)
        XCTAssertEqual(scanDelegate.scanresults[3].wifi.bssid, WifiInfo.wifi2.bssid)
        XCTAssertEqual(scanDelegate.scanresults[3].rssi, -60)
        
        XCTAssertNoThrow(try provisioner.stopScan())
        
        wait(1)
        
        XCTAssertEqual(scanDelegate.isScanning, false)
        
    }
    
    func testFailureStartScan() throws {
        let provisioner = DeviceManager(deviceId: failedScanResultDevice.identifier.uuidString)
        provisioner.provisionerScanDelegate = scanDelegate
        provisioner.connect()
        
        wait(1)
        
        XCTAssertNoThrow(try provisioner.startScan(scanParams: ScanParams()))
        
        wait(2)
        
        XCTAssertNil(scanDelegate.isScanning)
        XCTAssertNotNil(scanDelegate.startScanError)
        
        XCTAssertNoThrow(try provisioner.stopScan())
        
        wait(1)
        XCTAssertNotNil(scanDelegate.stopScanError)
    }
}
