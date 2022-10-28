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
            noServiceDevice, badVersionDataDevice, wifiDevice
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
                try self.dummy()
            } catch let e {
                print(e.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 2)
    }


    func testEmptyData() throws {
        let failedProvisioner = InternalProvisioner(deviceId: badVersionDataDevice.identifier.uuidString)
        failedProvisioner.infoDelegate = infoDelegate
        failedProvisioner.connect()
        
        let exp = expectation(description: "Not Connected")
        
        let group = DispatchGroup()
        
        group.enter()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            defer {
                group.leave()
            }
            
            do {
                XCTAssertNoThrow(try failedProvisioner.readVersion())
                try self.dummy()
            } catch {
                
            }
        }
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            defer {
                group.leave()
            }
            XCTAssertNotNil(self.infoDelegate.version)
            guard let version = self.infoDelegate.version else { return }
            switch version {
            case .success:
                XCTAssert(false, "Sholud be error")
            case .failure(let e):
                switch e {
                case .badData:
                    XCTAssert(true)
                default:
                    XCTAssertFalse(false, "Sholud be `badData` error")
                }
            }
        }
        
        group.notify(queue: .main) {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testConnectVersion() {
        let provisioner = InternalProvisioner(deviceId: wifiDevice.identifier.uuidString)
        provisioner.infoDelegate = infoDelegate
        provisioner.connect()
        
        let exp = expectation(description: "Version Expectation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            do {
                XCTAssertNoThrow(try provisioner.readVersion())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    defer {
                        exp.fulfill()
                    }
                    XCTAssertNotNil(self.infoDelegate.version)
                    guard let version = self.infoDelegate.version else { return }
                    switch version {
                    case .success(let v):
                        XCTAssertEqual(v, 17)
                    case .failure:
                        XCTAssert(false, "Should not be error")
                    }
                }
                try self.dummy()
            } catch {
                
            }
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testProvisionedStatus() {
        let provisioner = InternalProvisioner(deviceId: wifiDevice.identifier.uuidString)
        provisioner.infoDelegate = infoDelegate
        provisioner.connect()
        
        let exp = expectation(description: "Provisioned Status Expectation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            do {
                try self.dummy()
                XCTAssertNoThrow(try provisioner.readProvisioningStatus())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    
                }
            } catch {
                
            }
        }
    }
    
    private func dummy() throws {
        // MARK: Empty throws method to get rid off warnings
    }
}
