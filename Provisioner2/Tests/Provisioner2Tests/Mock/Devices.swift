//
//  File.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import Foundation
import CoreBluetoothMock

@testable import Provisioner2

let perihpheralUUID             = "14387800-130C-49E7-B877-2881C89CB260"
let notConnectableUUID          = "14387800-130C-49E7-B877-2881C89CB261"
let noServiceDeviceUUID         = "14387800-130C-49E7-B877-2881C89CB262"
let noVersionDeviceUUID         = "14387800-130C-49E7-B877-2881C89CB263"
let badVersionDeviceUUID        = "14387800-130C-49E7-B877-2881C89CB264"
let invalidArgumentDeviceUUID   = "14387800-130C-49E7-B877-2881C89CB265"
let invalidProtoDeviceUUID      = "14387800-130C-49E7-B877-2881C89CB266"
let internalErrorDeviceUUID     = "14387800-130C-49E7-B877-2881C89CB267"

struct PeripheralFactory {
    static func build(uuid: String, name: String, delegate: CBMPeripheralSpecDelegate) -> CBMPeripheralSpec {
        return CBMPeripheralSpec
            .simulatePeripheral(
                identifier: UUID(uuidString: uuid)!,
                proximity: .near
            )
            .advertising(
                    advertisementData: [
                        CBMAdvertisementDataLocalNameKey    : name,
                        CBMAdvertisementDataServiceUUIDsKey : [CBMUUID.wifi],
                        CBMAdvertisementDataIsConnectable   : true as NSNumber,
                        CBMAdvertisementDataServiceDataKey   : [
                            CBMUUID.wifi : Data([
                                0x11, // Version: 0x11 == 17
                                0x00, // Reserved
                                0x03, // Flags: 0b 00 00 00 11. 1 (second bit) - connected; 1 (first bit) - provisioned
                                0xC9  // Wi-Fi RSSI: 0xC9 == 0b11001001 == -55
                            ])
                        ]
                    ],
                    withInterval: 0.250,
                    alsoWhenConnected: false
            )
            .connectable(
                    name: name,
                    services: [
                        WiFiService()
                    ],
                    delegate: delegate,
                    connectionInterval: 0.150,
                    mtu: 23)
            .allowForRetrieval()
            .build()
    }
}

let wifiDevice              = PeripheralFactory.build(uuid: perihpheralUUID, name: "nRF-Wi-Fi", delegate: WifiDeviceDelegate())
let notConnectableDevice    = PeripheralFactory.build(uuid: notConnectableUUID, name: "Not Connectable", delegate: NotConnoctableWiFiDelegate())
let noServiceDevice         = PeripheralFactory.build(uuid: notConnectableUUID, name: "No Services", delegate: NoServicesWiFiDelegate())

// MARK: No Version Data
class NoVersionDataDelegate: WifiDeviceDelegate {
    override func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor characteristic: CBMCharacteristicMock) -> Result<Data, Error> {
        return .failure(NSError(domain: "NoVersionDataDelegate", code: -1))
    }
}
let noVersionDataDevice = PeripheralFactory.build(uuid: noVersionDeviceUUID, name: "No Version", delegate: NoVersionDataDelegate())

// MARK: Bad Version Data
class BadVersionDataDelegate: WifiDeviceDelegate {
    override func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor characteristic: CBMCharacteristicMock) -> Result<Data, Error> {
        return .success(Data())
    }
}
let badVersionDataDevice = PeripheralFactory.build(uuid: badVersionDeviceUUID, name: "Bad Version", delegate: BadVersionDataDelegate())

// MARK: Bad Device Response

let invalidArgumentDevice = PeripheralFactory.build(
    uuid: invalidArgumentDeviceUUID,
    name: "Invalid Argument",
    delegate: FailWifiStatusDelegate(failure: .some(.invalidArgument))
)

let invalidProtoDevice = PeripheralFactory.build(
    uuid: invalidProtoDeviceUUID,
    name: "Invalid Proto",
    delegate: FailWifiStatusDelegate(failure: .some(.invalidProto))
)

let internalErrorDevice = PeripheralFactory.build(
    uuid: internalErrorDeviceUUID,
    name: "Internal Error",
    delegate: FailWifiStatusDelegate(failure: .some(.internalError))
)

/*
 case 0: self = .success
 case 1: self = .invalidArgument
 case 2: self = .invalidProto
 case 3: self = .internalError
 */
