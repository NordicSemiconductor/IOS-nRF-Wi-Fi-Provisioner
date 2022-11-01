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
            noServiceDevice, badVersionDataDevice, wifiDevice,
            invalidArgumentDevice, invalidProtoDevice, internalErrorDevice
        ])
        CBMCentralManagerMock.simulatePowerOn()
        
        connectionDelegate = MockProvisionerDelegate()
        infoDelegate = MockProvisionerInfoDelegate()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        CBMCentralManagerMock.tearDownSimulation()
    }
    
    func testNotConnectedThrowing() {
        let failedProvisioner = InternalProvisioner(deviceId: noServiceDevice.identifier.uuidString)
        failedProvisioner.infoDelegate = infoDelegate
        failedProvisioner.connect()
        
        wait(1)
        
        XCTAssertThrowsError(try failedProvisioner.readVersion(), "Not connected error should be thrown")
        XCTAssertThrowsError(try failedProvisioner.readDeviceStatus(), "Not connected error should be thrown")
    }
    
    func testEmptyData() throws {
        let failedProvisioner = InternalProvisioner(deviceId: badVersionDataDevice.identifier.uuidString)
        failedProvisioner.infoDelegate = infoDelegate
        failedProvisioner.connect()
        
        wait(1)
        XCTAssertNoThrow(try failedProvisioner.readVersion())
        
        wait(1)
        let version = try XCTUnwrap(self.infoDelegate.version)
        
        switch version {
        case .success:
            XCTFail("Sholud be error")
        case .failure(let e):
            switch e {
            case .badData:
                XCTAssert(true)
            default:
                XCTFail("Sholud be `badData` error")
            }
        }
    }
    
    func testConnectVersion() throws {
        let provisioner = InternalProvisioner(deviceId: wifiDevice.identifier.uuidString)
        provisioner.infoDelegate = infoDelegate
        provisioner.connect()
        
        wait(1)
        XCTAssertNoThrow(try provisioner.readVersion())
        wait(1)
        
        let version = try XCTUnwrap(self.infoDelegate.version)
        switch version {
        case .success(let v):
            XCTAssertEqual(v, 17)
        case .failure:
            XCTFail("Should not be error")
        }
    }
    
    // MARK: Test failed response
    func testInvalidArgument() throws {
        let provisioner = InternalProvisioner(deviceId: invalidArgumentDevice.identifier.uuidString)
        provisioner.infoDelegate = infoDelegate
        provisioner.connect()
        
        wait(1)
        XCTAssertNoThrow(try provisioner.readDeviceStatus())
        
        wait(1)
        let status = try XCTUnwrap(self.infoDelegate.deviceStatus)
        switch status {
        case .success(_):
            XCTFail("Status sholud be failed")
        case .failure(let e):
            if case .deviceFailureResponse = e {
                XCTAssert(true)
            } else {
                XCTFail("error should be deviceFailureResponse")
            }
        }
    }
    
    func testInvalidProto() throws {
        let provisioner = InternalProvisioner(deviceId: invalidProtoDevice.identifier.uuidString)
        provisioner.infoDelegate = infoDelegate
        provisioner.connect()
        
        wait(1)
        XCTAssertNoThrow(try provisioner.readDeviceStatus())
        
        wait(1)
        let status = try XCTUnwrap(self.infoDelegate.deviceStatus)
        switch status {
        case .success(_):
            XCTFail("Status sholud be failed")
        case .failure(let e):
            if case .deviceFailureResponse = e {
                XCTAssert(true)
            } else {
                XCTFail("error should be deviceFailureResponse")
            }
        }
    }
    
    func testInternalError() throws {
        let provisioner = InternalProvisioner(deviceId: internalErrorDevice.identifier.uuidString)
        provisioner.infoDelegate = infoDelegate
        provisioner.connect()
        
        wait(1)
        XCTAssertNoThrow(try provisioner.readDeviceStatus())
        
        wait(1)
        let status = try XCTUnwrap(self.infoDelegate.deviceStatus)
        switch status {
        case .success(_):
            XCTFail("Status sholud be failed")
        case .failure(let e):
            if case .deviceFailureResponse = e {
                XCTAssert(true)
            } else {
                XCTFail("error should be deviceFailureResponse")
            }
        }
    }
    
    func testSucceedStatus() throws {
        let provisioner = InternalProvisioner(deviceId: wifiDevice.identifier.uuidString)
        provisioner.infoDelegate = infoDelegate
        provisioner.connect()
        
        wait(1)
        XCTAssertNoThrow(try provisioner.readDeviceStatus())
        
        wait(1)
        let status = try XCTUnwrap(self.infoDelegate.deviceStatus)
        switch status {
        case .success(let status):
            let wifiInfo = try XCTUnwrap(status.provisioningInfo)
            
            XCTAssertEqual(wifiInfo.ssid, "Nordic Guest")
            XCTAssertEqual(wifiInfo.bssid, MACAddress(data: 0xFA_23_1A_2B_3D_0A.toData()))
            XCTAssertEqual(wifiInfo.auth, .wpa2Psk)
            XCTAssertEqual(wifiInfo.band, .band5Gh)
            XCTAssertEqual(wifiInfo.channel, 6)
            
            let connectionInfo = try XCTUnwrap(status.connectionInfo)
            XCTAssertEqual(connectionInfo.ip, IPAddress(data: Data()))
            
            let scanParam = try XCTUnwrap(status.scanInfo)
            XCTAssertEqual(scanParam.band, .band24Gh)
            XCTAssertEqual(scanParam.groupChannels, 1)
            XCTAssertEqual(scanParam.passive, false)
            XCTAssertEqual(scanParam.periodMs, 1)
            
            let state = try XCTUnwrap(status.state)
            XCTAssertEqual(state, .connected)
        case .failure:
            XCTFail("Sholud be seccess")
        }
    }
}
