//
//  Screenshots.swift
//  Screenshots
//
//  Created by Dinesh Harjani on 14/5/24.
//

import XCTest

final class Screenshots: XCTestCase {

    @MainActor
    func testStartInfo() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments =  ["always-show-intro"]
        setupSnapshot(app)
        app.launch()

        XCTAssertTrue(app.staticTexts["nRF Wi-Fi Provisioner"].exists)
        snapshot("01-launch")
    }
    
    @MainActor
    func testSelectorView() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let provisionOverBleButton = app.buttons["selector_ble_provisioning_btn"]
        XCTAssertTrue(provisionOverBleButton.waitForExistence(timeout: 1))
        snapshot("02-selector")
    }
    
    @MainActor
    func testProvisionOverBleView() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        let provisionOverBleButton = app.buttons["selector_ble_provisioning_btn"]
        XCTAssertTrue(provisionOverBleButton.waitForExistence(timeout: 1))
        provisionOverBleButton.tap()
        
        let bleProvisioning = app.staticTexts["Scanner"]
        XCTAssertTrue(bleProvisioning.waitForExistence(timeout: 1))
        snapshot("03-bleProvisioning")
    }
    
    @MainActor
    func testProvisionOverWiFiView() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        let provisionOverWiFiButton = app.buttons["selector_wifi_provisioning_btn"]
        XCTAssertTrue(provisionOverWiFiButton.waitForExistence(timeout: 1))
        provisionOverWiFiButton.tap()
        
        let wifiProvisioning = app.staticTexts["Provision over Wi-Fi"]
        XCTAssertTrue(wifiProvisioning.waitForExistence(timeout: 1))
        snapshot("04-wifiProvisioning")
    }
    
    @MainActor
    func testProvisionOverNFCView() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        let provisionOverBleButton = app.buttons["selector_nfc_provisioning_btn"]
        XCTAssertTrue(provisionOverBleButton.waitForExistence(timeout: 1))
        provisionOverBleButton.tap()
        
        let nfcProvisioning = app.staticTexts["Provision over NFC"]
        XCTAssertTrue(nfcProvisioning.waitForExistence(timeout: 1))
        snapshot("05-nfcProvisioning")
    }
}
