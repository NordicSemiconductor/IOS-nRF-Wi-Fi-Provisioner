//
//  ProvisionerTests.swift
//  
//
//  Created by Nick Kibysh on 11/10/2022.
//

import XCTest
import CoreBluetoothMock
@testable import NordicWiFiProvisioner

final class ProvisionerConnectionTests: XCTestCase {
    var scanner: NordicWiFiProvisioner.Scanner!
    var scannerDelegate: MockScanDelegate!
    var connectionDelegate: MockProvisionerConnectionDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals([
            notConnectableDevice, wifiDevice
        ])
        
        scannerDelegate = MockScanDelegate()
        connectionDelegate = MockProvisionerConnectionDelegate()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        CBMCentralManagerMock.tearDownSimulation()
    }
    
    func testBadStateConnection() throws {
        let failedProvisioner = DeviceManager(deviceId: UUID())
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        CBMCentralManagerMock.simulatePowerOff()
        
        wait(1)
        
        let e = try XCTUnwrap(self.connectionDelegate.connectionError)
        let provE = try XCTUnwrap(e as? ProvisionerError)
        
        switch provE {
        case .bluetoothNotAvailable:
            XCTAssert(true)
        default:
            XCTFail("`bluetoothNotAvailable` expected")
        }
    }
    
    func testNoPeripheralFonud() throws {
        let failedProvisioner = DeviceManager(deviceId: UUID())
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        CBMCentralManagerMock.simulatePowerOn()
        
        wait(1)
        
        let e = try XCTUnwrap(self.connectionDelegate.connectionError)
        let provE = try XCTUnwrap(e as? ProvisionerError)
        
        switch provE {
        case .noPeripheralFound:
            XCTAssert(true)
        default:
            XCTFail("`noPeripheralFound` expected")
        }
    }
    
    func testNotConnected() throws {
        let failedProvisioner = DeviceManager(deviceId: notConnectableDevice.identifier)
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        CBMCentralManagerMock.simulatePowerOn()
        
        wait(1)
        
        let e = try XCTUnwrap(self.connectionDelegate.connectionError)
        let provE = try XCTUnwrap(e as? ProvisionerError)
        
        switch provE {
        case .notConnected:
            XCTAssert(true)
        default:
            XCTFail("`notConnected` expected")
        }
    }
    
    func testSuccessConnection() {
        let failedProvisioner = DeviceManager(deviceId: wifiDevice.identifier)
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        CBMCentralManagerMock.simulatePowerOn()
        
        wait(1)
        
        XCTAssertNil(self.connectionDelegate.connectionError, "There should not be error")
        XCTAssertTrue(self.connectionDelegate.connected, "Device should be connected")
    }
    
    func testBluetoothStateChanging() {
        let failedProvisioner = DeviceManager(deviceId: wifiDevice.identifier)
        failedProvisioner.connectionDelegate = connectionDelegate
        failedProvisioner.connect()
        
        wait(1)
        CBMCentralManagerMock.simulatePowerOn()
        
        wait(1)
        CBMCentralManagerMock.simulatePowerOff()
        
        wait(1)
        XCTAssertNotNil(self.connectionDelegate.connectionError, "Error should exist after contral manager powered off")
        failedProvisioner.connect()
        CBMCentralManagerMock.simulatePowerOn()
        
        wait(1)
        XCTAssertNil(self.connectionDelegate.connectionError, "There should not be error")
        XCTAssertTrue(self.connectionDelegate.connected, "Device should be connected")
    }
}
