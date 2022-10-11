//
//  ScannerTests.swift
//  
//
//  Created by Nick Kibysh on 11/10/2022.
//

import XCTest
@testable import Provisioner2

final class ScannerTests: XCTestCase {

    override func setUpWithError() throws {
        AppConfigurator.setup()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBluetoothStatus() throws {
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
