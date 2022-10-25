//
//  ProvisionerInfoTests.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import XCTest
import CoreBluetoothMock
@testable import Provisioner2

final class ProvisionerInfoTests: XCTestCase {
    var connectionDelegate: MockProvisionerDelegate!
    var infoDelegate: MockProvisionerInfoDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals([
            noServiceDevice
        ])
        CBMCentralManagerMock.simulatePowerOn()
        
        connectionDelegate = MockProvisionerDelegate()
        infoDelegate = MockProvisionerInfoDelegate()
    }
    
    func testNotConnectedThrowing() {
        let failedProvisioner = InternalProvisioner(deviceId: noServiceDevice.identifier.uuidString)
        failedProvisioner.infoDelegate = infoDelegate
        failedProvisioner.connect()
        
        let exp = expectation(description: "Not Connected")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            do {
                XCTAssertThrowsError(try failedProvisioner.readVersion(), "Not connected error should be thrown")
                XCTAssertThrowsError(try failedProvisioner.readWiFiStatus(), "Not connected error should be thrown")
                XCTAssertThrowsError(try failedProvisioner.readProvisioningStatus(), "Not connected error should be thrown")
                exp.fulfill()
            } catch let e {
                print(e.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 2)
    }
    
    
}
