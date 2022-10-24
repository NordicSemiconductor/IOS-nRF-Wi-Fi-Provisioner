//
//  ProvisionerTests.swift
//  
//
//  Created by Nick Kibysh on 11/10/2022.
//

import XCTest
import CoreBluetoothMock
@testable import Provisioner2

final class ProvisionerConnectionTests: XCTestCase {
    var scanner: Provisioner2.Scanner!
    var scannerDelegate: MockScanDelegate!
    var connectionDelegate: MockProvisionerDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals([
            notConnectableDevice, wifiDevice
        ])
        
        scannerDelegate = MockScanDelegate()
        scanner = Provisioner2.Scanner(delegate: scannerDelegate)
        connectionDelegate = MockProvisionerDelegate()
    }
    
    func testBadIdentifierConnection() {
        let failedProvisioner = InternalProvisioner(deviceId: "")
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        let errorExp = expectation(description: "Wrong UUID Expectation")
        
        CBMCentralManagerMock.simulatePowerOn()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.connectionDelegate.connectionError)
            if let e = self.connectionDelegate.connectionError {
                XCTAssertTrue(e is ProvisionerError)
                if let provE = e as? ProvisionerError {
                    guard case .badIdentifier = provE else {
                        XCTAssert(false, "`badIdentifier` expected")
                        return
                    }
                }
            }
            errorExp.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testBadStateConnection() {
        let failedProvisioner = InternalProvisioner(deviceId: "")
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        let errorExp = expectation(description: "Bad Bluetooth State expectation")
        
        CBMCentralManagerMock.simulatePowerOff()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.connectionDelegate.connectionError)
            if let e = self.connectionDelegate.connectionError {
                XCTAssertTrue(e is ProvisionerError)
                if let provE = e as? ProvisionerError {
                    guard case .bluetoothNotAvailable = provE else {
                        XCTAssert(false, "`bluetoothNotAvailable` expected")
                        return
                    }
                }
            }
            errorExp.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testNoPeripheralFonud() {
        let failedProvisioner = InternalProvisioner(deviceId: UUID().uuidString)
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        let errorExp = expectation(description: "No Peripheral found expectation")
        
        CBMCentralManagerMock.simulatePowerOn()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.connectionDelegate.connectionError)
            if let e = self.connectionDelegate.connectionError {
                XCTAssertTrue(e is ProvisionerError)
                if let provE = e as? ProvisionerError {
                    guard case .noPeripheralFound = provE else {
                        XCTAssert(false, "`noPeripheralFound` expected")
                        return
                    }
                }
            }
            errorExp.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testNotConnected() {
        let failedProvisioner = InternalProvisioner(deviceId: notConnectableDevice.identifier.uuidString)
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        let errorExp = expectation(description: "Not Connected expectation")
        
        CBMCentralManagerMock.simulatePowerOn()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.connectionDelegate.connectionError)
            if let e = self.connectionDelegate.connectionError {
                XCTAssertTrue(e is ProvisionerError)
                if let provE = e as? ProvisionerError {
                    guard case .notConnected = provE else {
                        XCTAssert(false, "`notConnected` expected")
                        return
                    }
                }
            }
            errorExp.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testSuccessConnection() {
        let failedProvisioner = InternalProvisioner(deviceId: wifiDevice.identifier.uuidString)
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        let errorExp = expectation(description: "Connected expectation")
        
        CBMCentralManagerMock.simulatePowerOn()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNil(self.connectionDelegate.connectionError, "There should not be error")
            XCTAssertTrue(self.connectionDelegate.connected, "Device should be connected")
            errorExp.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testBluetoothStateChanging() {
        let failedProvisioner = InternalProvisioner(deviceId: wifiDevice.identifier.uuidString)
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        let errorExp = expectation(description: "Connected expectation")
        
        DispatchQueue.global().async {
            sleep(1)
            DispatchQueue.main.async {
                CBMCentralManagerMock.simulatePowerOn()
            }
            sleep(1)
            DispatchQueue.main.async {
                CBMCentralManagerMock.simulatePowerOff()
            }
            sleep(1)
            DispatchQueue.main.async {
                failedProvisioner.connect()
                CBMCentralManagerMock.simulatePowerOn()
            }
            sleep(1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                XCTAssertNil(self.connectionDelegate.connectionError, "There should not be error")
                XCTAssertTrue(self.connectionDelegate.connected, "Device should be connected")
                errorExp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
}
