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
    var connectionDelegate: MockProvisionerConnectionDelegate!
    var infoDelegate: MockProvisionerInfoDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals([
            noServiceDevice, badVersionDataDevice, wifiDevice,
            invalidArgumentDevice, invalidProtoDevice, internalErrorDevice
        ])
        CBMCentralManagerMock.simulatePowerOn()
        
        connectionDelegate = MockProvisionerConnectionDelegate()
        infoDelegate = MockProvisionerInfoDelegate()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        CBMCentralManagerMock.tearDownSimulation()
    }
    
    func testNotConnectedThrowing() {
        let failedProvisioner = Provisioner(deviceId: noServiceDevice.identifier.uuidString)
        failedProvisioner.infoDelegate = infoDelegate
        failedProvisioner.connect()
        
        wait(1)
        
        XCTAssertThrowsError(try failedProvisioner.readVersion(), "Not connected error should be thrown")
        XCTAssertThrowsError(try failedProvisioner.readDeviceStatus(), "Not connected error should be thrown")
    }
    
    func testEmptyData() throws {
        let failedProvisioner = Provisioner(deviceId: badVersionDataDevice.identifier.uuidString)
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
        let provisioner = Provisioner(deviceId: wifiDevice.identifier.uuidString)
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
        let provisioner = Provisioner(deviceId: invalidArgumentDevice.identifier.uuidString)
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
            if case .invalidArgument = e {
                XCTAssert(true)
            } else {
                XCTFail("error should be invalidArgument")
            }
        }
    }
    
    func testInvalidProto() throws {
        let provisioner = Provisioner(deviceId: invalidProtoDevice.identifier.uuidString)
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
            if case .failedToDecodeRequest = e {
                XCTAssert(true)
            } else {
                XCTFail("error should be failedToDecodeRequest")
            }
        }
    }
    
    func testInternalError() throws {
        let provisioner = Provisioner(deviceId: internalErrorDevice.identifier.uuidString)
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
            if case .internalError = e {
                XCTAssert(true)
            } else {
                XCTFail("error should be internalError")
            }
        }
    }
    
    func testSucceedStatus() throws {
        let provisioner = Provisioner(deviceId: wifiDevice.identifier.uuidString)
        provisioner.infoDelegate = infoDelegate
        provisioner.connect()
        
        wait(1)
        XCTAssertNoThrow(try provisioner.readDeviceStatus())
        
        wait(1)
        let status = try XCTUnwrap(self.infoDelegate.deviceStatus)
        switch status {
        case .success(let status):
            let wifiInfo = try XCTUnwrap(status.provisioningInfo)
            /*
             ssid: "WiFi-1",
             bssid: MACAddress.mac1,
             band: .band24Gh,
             channel: 1,
             auth: .open
             */
            /// Look at mock in ``Provisioner2/Tests/Provisioner2Tests/Provisioner/ProvisionerInfoTests.swift``
            XCTAssertEqual(wifiInfo.ssid, "WiFi-1")
            XCTAssertEqual(wifiInfo.bssid, MACAddress.mac1)
            XCTAssertEqual(wifiInfo.auth, .open)
            XCTAssertEqual(wifiInfo.band, .band24Gh)
            XCTAssertEqual(wifiInfo.channel, 1)
            
            let connectionInfo = try XCTUnwrap(status.connectionInfo)
            XCTAssertEqual(connectionInfo.ip?.description, "255.255.255.255")
            
            /*
             Look at mock in ``Tests/Provisioner2Tests/Mock/Model+Extensions/ScanParams+Ext.swift:12``
             band: .band5Gh,
             passive: true,
             periodMs: 100,
             groupChannels: 1
             */
            
            /// ``../Mock/Model+Extensions/ScanParams+Ext.swift``
            let scanParam = try XCTUnwrap(status.scanInfo)
            XCTAssertEqual(scanParam.band, .band5Gh)
            XCTAssertEqual(scanParam.groupChannels, 1)
            XCTAssertEqual(scanParam.passive, true)
            XCTAssertEqual(scanParam.periodMs, 100)
            
            let state = try XCTUnwrap(status.state)
            XCTAssertEqual(state, .connected)
        case .failure:
            XCTFail("Sholud be seccess")
        }
    }
}
