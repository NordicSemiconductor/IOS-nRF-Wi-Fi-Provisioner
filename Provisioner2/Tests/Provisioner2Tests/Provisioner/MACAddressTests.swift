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

}
