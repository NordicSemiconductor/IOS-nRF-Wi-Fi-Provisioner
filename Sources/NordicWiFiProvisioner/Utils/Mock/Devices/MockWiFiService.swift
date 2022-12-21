//
//  File.swift
//  
//
//  Created by Nick Kibysh on 16/12/2022.
//

import Foundation
import CoreBluetoothMock

class MockWiFiService: CBMServiceMock {
    init() {
        super.init(
                type: .wifi,
                primary: true,
                characteristics: [
                    .version,
                    .controlPoint,
                    .dataOut
                ])
    }
}
