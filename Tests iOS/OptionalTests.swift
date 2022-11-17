//
//  OptionalTests.swift
//  Tests iOS
//
//  Created by Nick Kibysh on 16/11/2022.
//

import XCTest
@testable import nRF_Wi_Fi_Provisioner

final class OptionalTests: XCTestCase {
    func testExample() {
        let a: Int? = 0
        let b: Int? = nil
        
        XCTAssertGreaterThan(a, b)
        XCTAssertLessThan(b, a)
        
        let c: Int? = -1
        let d: Int? =  1
        
        XCTAssertGreaterThan(c, d)
        XCTAssertLessThan(c, d)
        
        let e: Int? = nil
        let f: Int? = nil
        XCTAssertGreaterThan(e, f)
        XCTAssertLessThan(e, f)
    }
}
