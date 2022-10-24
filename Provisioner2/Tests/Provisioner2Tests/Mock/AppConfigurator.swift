//
//  AppConfigurator.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 23/09/2022.
//

import CoreBluetoothMock
import Foundation

let perihpheralUUID     = "14387800-130C-49E7-B877-2881C89CB260"
let notConnectableUUID  = "14387800-130C-49E7-B877-2881C89CB261"

extension CBMUUID {
    static let version =        CBMUUID(string: "14387801-130c-49e7-b877-2881c89cb258")
    static let controlPoint =   CBMUUID(string: "14387802-130c-49e7-b877-2881c89cb258")
    static let dataOut =        CBMUUID(string: "14387803-130c-49e7-b877-2881c89cb258")
    static let wifi =           CBMUUID(string: "14387800-130c-49e7-b877-2881c89cb258")
}

extension CBMCharacteristicMock {
    static let version = CBMCharacteristicMock(type: .version, properties: [.read])
    static let controlPoint = CBMCharacteristicMock(type: .controlPoint, properties: [.write, .notify])
    static let dataOut = CBMCharacteristicMock(type: .dataOut, properties: [.notify])
}

private class WiFiService: CBMServiceMock {
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

let wifiDevice = CBMPeripheralSpec
        .simulatePeripheral(
            identifier: UUID(uuidString: perihpheralUUID)!,
            proximity: .near
        )
        .advertising(
                advertisementData: [
                    CBMAdvertisementDataLocalNameKey    : "nRF-Wi-Fi",
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
                name: "nRF Wi-Fi",
                services: [
                    WiFiService()
                ],
                delegate: WifiDeviceDelegate(),
                connectionInterval: 0.150,
                mtu: 23)
        .allowForRetrieval()
        .build()

let notConnectableDevice = CBMPeripheralSpec
    .simulatePeripheral(
        identifier: UUID(uuidString: notConnectableUUID)!,
        proximity: .near
    )
    .advertising(
            advertisementData: [
                CBMAdvertisementDataLocalNameKey    : "Not Connectable Device",
                CBMAdvertisementDataServiceUUIDsKey : [CBMUUID.wifi],
                CBMAdvertisementDataIsConnectable   : false as NSNumber
            ],
            withInterval: 0.250
    )
    .connectable(
            name: "nRF Wi-Fi",
            services: [
                WiFiService()
            ],
            delegate: NotConnoctableWiFiDelegate(),
            connectionInterval: 0.150,
            mtu: 23)
    .allowForRetrieval()
    .build()

public class AppConfigurator {
    public static func setup() {
        CBMCentralManagerMock.simulateInitialState(.poweredOff)
        CBMCentralManagerMock.simulatePeripherals([
            wifiDevice
        ])
        CBMCentralManagerMock.simulatePowerOn()
    }
}
