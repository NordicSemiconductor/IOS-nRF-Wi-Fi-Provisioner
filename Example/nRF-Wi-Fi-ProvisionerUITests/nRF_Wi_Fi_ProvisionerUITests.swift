//
//  nRF_Wi_Fi_ProvisionerUITests.swift
//  nRF-Wi-Fi-ProvisionerUITests
//
//  Created by Nick Kibysh on 30/09/2022.
//

import XCTest

final class nRF_Wi_Fi_ProvisionerUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFullUserFlow() throws {
        let startButton = app.buttons["start_provisioning_btn"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 1))
        snapshot("01-launch")
        startButton.tap()
        
        let sidebar = app.buttons["ToggleSidebar"]
        if sidebar.exists {
            sidebar.tap()
        } else {
            let backButton = app.buttons["BackButton"]
            if backButton.exists {
                backButton.tap()
            }
        }
        
        let firstScanResult = app.buttons["scan_result_0"]
        XCTAssertTrue(firstScanResult.waitForExistence(timeout: 5))
        snapshot("02-scan-result")
        firstScanResult.tap()
        
        let accessPointSelector = app.staticTexts["access_point_selector"].firstMatch
        
        XCTAssertTrue(accessPointSelector.waitForExistence(timeout: 5))
        snapshot("03-device-details")
                accessPointSelector.tap()
        
        // Find third access point
        // .accessibility(identifier: "access_point_\(viewModel.accessPoints.firstIndex(of: accessPoint) ?? -1)")
        let thirdAccessPoint = app.buttons["access_point_0"]
        
        XCTAssertTrue(thirdAccessPoint.waitForExistence(timeout: 2))
        snapshot("04-access-point-list")
        thirdAccessPoint.tap()
        
        let text = app.collectionViews.firstMatch.staticTexts.firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 2))
        snapshot("05-channel-selector")
        
        
                text.tap()
    }
}
