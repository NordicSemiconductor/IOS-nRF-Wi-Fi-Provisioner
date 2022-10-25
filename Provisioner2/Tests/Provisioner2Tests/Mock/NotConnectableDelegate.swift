//
//  File.swift
//  
//
//  Created by Nick Kibysh on 21/10/2022.
//

import Foundation
import CoreBluetoothMock

class NotConnoctableWiFiDelegate: WifiDeviceDelegate {
    override func peripheralDidReceiveConnectionRequest(_ peripheral: CBMPeripheralSpec) -> Result<(), Error> {
        return .failure(NSError(domain: "NotConnoctableWiFiDelegate", code: 1))
    }
}

class NoServicesWiFiDelegate: WifiDeviceDelegate {
    override func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?) -> Result<(), Error> {
        return .failure(NSError(domain: "NoServicesWiFiDelegate", code: 2))
    }
}
