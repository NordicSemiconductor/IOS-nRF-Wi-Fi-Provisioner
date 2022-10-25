//
//  File.swift
//  
//
//  Created by Nick Kibysh on 24/10/2022.
//

import Foundation
import CoreBluetoothMock

let perihpheralUUID     = "14387800-130C-49E7-B877-2881C89CB260"
let notConnectableUUID  = "14387800-130C-49E7-B877-2881C89CB261"
let noServiceDeviceUUID = "14387800-130C-49E7-B877-2881C89CB262"

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
            name: "nRF Wi-Fi (Not Connectable)",
            services: [
                WiFiService()
            ],
            delegate: NotConnoctableWiFiDelegate(),
            connectionInterval: 0.150,
            mtu: 23)
    .allowForRetrieval()
    .build()

let noServiceDevice = CBMPeripheralSpec
    .simulatePeripheral(
        identifier: UUID(uuidString: noServiceDeviceUUID)!,
        proximity: .near
    )
    .advertising(
            advertisementData: [
                CBMAdvertisementDataLocalNameKey    : "So Service Device",
                CBMAdvertisementDataServiceUUIDsKey : [CBMUUID.wifi],
                CBMAdvertisementDataIsConnectable   : false as NSNumber
            ],
            withInterval: 0.250
    )
    .connectable(
            name: "nRF Wi-Fi (No Service)",
            services: [
                WiFiService()
            ],
            delegate: NoServicesWiFiDelegate(),
            connectionInterval: 0.150,
            mtu: 23)
    .allowForRetrieval()
    .build()
