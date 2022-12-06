//
//  IPAdressTests.swift
//  
//
//  Created by Nick Kibysh on 04/11/2022.
//

import XCTest
@testable import NordicWiFiProvisioner

final class IPAdressTests: XCTestCase {
    
    func testTooBigDataIpAddress() throws {
        let d = 0x67_fa_01_02.toData().suffix(5)
        let ip = IPAddress(data: d)
        XCTAssertNil(ip, "Only 4 byte data is acceptable for IPv4 address")
    }
    
    func testTooSmallDataIpAddress() throws {
        let d = 0x67_fa_01_02.toData().suffix(3)
        let ip = IPAddress(data: d)
        XCTAssertNil(ip, "Only 4 byte data is acceptable for IPv4 address")
    }
    
    func testCorrectIpAddress1() {
        let d = 0x00_00_00_00.toData().suffix(4)
        let ip = IPAddress(data: d)
        XCTAssertEqual(ip?.description, "0.0.0.0")
    }
    
    func testCorrectIpAddress2() {
        let d = 0xff_ff_ff_ff.toData().suffix(4)
        let ip = IPAddress(data: d)
        XCTAssertEqual(ip?.description, "255.255.255.255")
    }
    
    func testCorrectIpAddress3() {
        let d = 0xc0_a8_01_01.toData().suffix(4) // 192.168.1.1
        let ip = IPAddress(data: d)
        XCTAssertEqual(ip?.description, "192.168.1.1")
    }
}
