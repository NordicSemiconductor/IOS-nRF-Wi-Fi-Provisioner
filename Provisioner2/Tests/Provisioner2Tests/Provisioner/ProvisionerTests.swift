//
//  ProvisionerTests.swift
//  
//
//  Created by Nick Kibysh on 18/11/2022.
//

import XCTest
import CoreBluetoothMock
@testable import Provisioner2

final class ProvisionerTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals([
            noServiceDevice, badVersionDataDevice, wifiDevice,
            invalidArgumentDevice, invalidProtoDevice, internalErrorDevice, scanResultDevice
        ])
        CBMCentralManagerMock.simulatePowerOn()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        CBMCentralManagerMock.tearDownSimulation()
    }
    
    func testProvisioner() throws {
        let provisioner = Provisioner(deviceId: wifiDevice.identifier.uuidString)
        let provDelegate = MockProvisionerDelegate()
        provisioner.provisionerDelegate = provDelegate
        
        XCTAssertThrowsError(try provisioner.setConfig(wifi: .wifi1, passphrase: "passphrase", volatileMemory: true), "Should throw error if provisioner is not connected")
        
        provisioner.connect()
        
        wait(1)
        
        XCTAssertNoThrow(try provisioner.setConfig(wifi: .wifi1, passphrase: "passphrase", volatileMemory: true))
        
        wait(10)
        
        let provisionerFromMethod = try XCTUnwrap(provDelegate.provisioner)
        
        XCTAssertTrue(provisionerFromMethod === provDelegate.provisioner, "Provisioner from delegate's method should be the same as provisioner which calls the method")
        
        XCTAssertEqual(provDelegate.states[0], .disconnected)
        XCTAssertEqual(provDelegate.states[1], .authentication)
        XCTAssertEqual(provDelegate.states[2], .association)
        XCTAssertEqual(provDelegate.states[3], .obtainingIp)
        XCTAssertEqual(provDelegate.states[4], .connected)
        
        XCTAssertEqual(provDelegate.failReasons[0], .authError)
        XCTAssertEqual(provDelegate.failReasons[1], .networkNotFound)
        XCTAssertEqual(provDelegate.failReasons[2], .timeout)
        XCTAssertEqual(provDelegate.failReasons[3], .failIp)
        XCTAssertEqual(provDelegate.failReasons[4], .failConn)
    }
}
