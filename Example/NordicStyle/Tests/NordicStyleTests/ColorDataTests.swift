//
//  ColorDataTests.swift
//  
//
//  Created by Nick Kibysh on 28/06/2022.
//

import XCTest
import SwiftUI
@testable import NordicStyle

class ColorDataTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHexInit() {
        let c = RGB(0xffffff)
        
        XCTAssertEqual(c.r, 1)
        XCTAssertEqual(c.g, 1)
        XCTAssertEqual(c.b, 1)
        
        let c2 = RGB(0x0)
        XCTAssertEqual(c2.r, 0)
        XCTAssertEqual(c2.g, 0)
        XCTAssertEqual(c2.b, 0)
        
        let c3 = RGB(0xcc_cc_cc)
        XCTAssertEqual(c3.r, 0.8)
        XCTAssertEqual(c3.g, 0.8)
        XCTAssertEqual(c3.b, 0.8)
    }
    
    func testIntInit() {
        let c = RGB(r: 255, g: 255, b: 255, a: 1)
        XCTAssertEqual(c.r, 1)
        XCTAssertEqual(c.g, 1)
        XCTAssertEqual(c.b, 1)
        
        let c2 = RGB(r: 0, g: 0, b: 0, a: 0)
        XCTAssertEqual(c2.r, 0)
        XCTAssertEqual(c2.g, 0)
        XCTAssertEqual(c2.b, 0)
        
        let c3 = RGB(r: 204, g: 204, b: 204, a: 0.5)
        XCTAssertEqual(c3.r, 0.8)
        XCTAssertEqual(c3.g, 0.8)
        XCTAssertEqual(c3.b, 0.8)
    }
    
}
