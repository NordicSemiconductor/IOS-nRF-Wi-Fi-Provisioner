//
//  ScannerTests.swift
//  
//
//  Created by Nick Kibysh on 11/10/2022.
//

import XCTest
@testable import Provisioner2

final class ScannerTests: XCTestCase {
    var scanner: Provisioner2.Scanner!
    var scannerDelegate: MockScanDelegate!

    override func setUpWithError() throws {
        AppConfigurator.setup()
        scannerDelegate = MockScanDelegate()
        scanner = Provisioner2.Scanner(delegate: scannerDelegate)
    }

    override func tearDownWithError() throws {
        scanner = nil
        scannerDelegate = nil 
    }

    func testBluetoothStatus() throws {
        let statusExp = expectation(description: "Manager Status Expectation")
        scannerDelegate.managerStatus = { s in
            if case .poweredOn = s {
                statusExp.fulfill()
            }
        }
        
        scanner.startScan()
        
        wait(for: [statusExp], timeout: 10)
    }
    
    func testScanStartStatus() {
        let startScanExp = expectation(description: "Start Scanning Exp")
        
        scannerDelegate.scanStatusHandler = { status in
            if status {
                startScanExp.fulfill()
            }
        }
        
        scanner.startScan()
        waitForExpectations(timeout: 10)
        XCTAssertTrue(scannerDelegate.isScanning)
    }
    
    func testScanStopStatus() {
        let startScanExp = expectation(description: "Stop Scanning Exp")
        
        scannerDelegate.scanStatusHandler = { status in
            if !status {
                startScanExp.fulfill()
            }
        }
        
        scanner.startScan()
        scanner.stopScan()
        
        waitForExpectations(timeout: 10)
        XCTAssertTrue(!scannerDelegate.isScanning)
    }
    
    func testScanResults() {
        let resultsExp = expectation(description: "Results")
        
        scannerDelegate.discoveredDevice = { _ in
            resultsExp.fulfill()
        }
        
        scanner.startScan()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertFalse(scannerDelegate.scanResults.isEmpty)
        
        XCTAssertNotNil(scannerDelegate.scanResults.first)
        
        let firstResult = scannerDelegate.scanResults.first!
        XCTAssertEqual((firstResult as? DiscoveredDevice)?.serviceByteArray?.count, 4)
        XCTAssertEqual(firstResult.name, "nRF-Wi-Fi")
        XCTAssertEqual(firstResult.wifiRSSI, -55)
        XCTAssertEqual(firstResult.id, perihpheralUUID)
        XCTAssertTrue(firstResult.provisioned)
        XCTAssertTrue(firstResult.connected)
        XCTAssertEqual(firstResult.version, 17)
    }
    
    func testScanning() {
        XCTAssertTrue(true)
    }

}
