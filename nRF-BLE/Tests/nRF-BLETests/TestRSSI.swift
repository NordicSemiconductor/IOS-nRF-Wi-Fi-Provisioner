//
//  TestRSSI.swift
//  
//
//  Created by Nick Kibysh on 15/07/2022.
//

import XCTest
import nRF_BLE

class TestRSSI: XCTestCase {
    func testSignalLevel() {
        let goodRssi = RSSI(level: 0)
        XCTAssertEqual(goodRssi.signal, .good)
        
        let okRssi = RSSI(level: -70)
        XCTAssertEqual(okRssi.signal, .ok)
        
        let badRssi = RSSI(level: -95)
        XCTAssertEqual(badRssi.signal, .bad)
        
        let veryBad = RSSI(level: -110)
        XCTAssertEqual(veryBad.signal, .practicalWorst)
        
        let outOfRange = RSSI(level: 5)
        XCTAssertEqual(outOfRange.signal, .outOfRange)
    }
}
