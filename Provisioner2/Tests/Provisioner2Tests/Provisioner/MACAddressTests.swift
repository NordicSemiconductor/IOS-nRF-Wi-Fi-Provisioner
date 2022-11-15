//
//  MACAddressTests.swift
//  
//
//  Created by Nick Kibysh on 04/11/2022.
//

import XCTest
@testable import Provisioner2

final class MACAddressTests: XCTestCase {

    func testMACAddress() throws {
        let data1 = Data()
        let mac1 = MACAddress(data: data1)
        XCTAssertNil(mac1)

        let mac4bytesValue = 0x00_00_00_00.toData()
        let mac2 = MACAddress(data: mac4bytesValue)
        XCTAssertNil(mac2)
        
        let connectValue1 = 0xaf_ff_bc_83_8a_f8.toData().suffix(6)
        let mac3 = MACAddress(data: connectValue1)
        XCTAssertNotNil(mac3)
        XCTAssertEqual(mac3?.description, "AF:FF:BC:83:8A:F8")
        
        let connectValue2 = 0x00_00_00_00_00_00.toData().suffix(6)
        let mac4 = MACAddress(data: connectValue2)
        XCTAssertNotNil(mac4)
        XCTAssertEqual(mac4?.description, "00:00:00:00:00:00")
    }
    
    func testMockMAC() throws {
        let mac1 = try XCTUnwrap(MACAddress.mac1)
        XCTAssertEqual(mac1.description, "01:02:03:04:05:06")
        
        let mac2 = try XCTUnwrap(MACAddress.mac2)
        XCTAssertEqual(mac2.description, "AA:BB:CC:DD:EE:FF")
        
        let mac3 = try XCTUnwrap(MACAddress.mac3)
        XCTAssertEqual(mac3.description, "1A:2B:3C:4D:5E:6F")
        
        let mac4 = try XCTUnwrap(MACAddress.mac4)
        XCTAssertEqual(mac4.description, "A1:B2:C3:D4:E5:F6")
    }

}
