//
//  nRF_Wi_Fi_ProvisionerUITests.swift
//  nRF-Wi-Fi-ProvisionerUITests
//
//  Created by Nick Kibysh on 30/09/2022.
//

import XCTest

final class nRF_Wi_Fi_ProvisionerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFullUserFlow() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        let startButton = app.buttons["start_provisioning_btn"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 1))
        startButton.tap()

        let firstScanResult = app.buttons["scan_result_0"]
        XCTAssertTrue(firstScanResult.waitForExistence(timeout: 5))
        firstScanResult.tap()

        // Find Access Point selector
        let accessPointSelector = app.buttons["access_point_selector"]
        XCTAssertTrue(accessPointSelector.waitForExistence(timeout: 5))
        accessPointSelector.tap()

        // Find third access point
        let thirdAccessPoint = app.buttons["access_point_0"]
        XCTAssertTrue(thirdAccessPoint.waitForExistence(timeout: 1))
        thirdAccessPoint.tap()
        
        let text = app.staticTexts["Channel 11"]
        XCTAssertTrue(text.waitForExistence(timeout: 2))
        
        text.tap()
        
        let rssiView = app.otherElements["rssi_view"]
        XCTAssertTrue(rssiView.waitForExistence(timeout: 1))
    }
}
