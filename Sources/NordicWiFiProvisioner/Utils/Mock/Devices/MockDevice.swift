//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/12/2022.
//

import CoreBluetoothMock
import Foundation

public protocol PeripheralMock {
    var spec: CBMPeripheralSpec { get }
}

open class Device: PeripheralMock {
    public let spec: CBMPeripheralSpec
    let name: String
    let uuidString: String
    let delegate: CBMPeripheralSpecDelegate
    
    init(name: String,
         uuidString: String,
         delegate: CBMPeripheralSpecDelegate,
         version: UInt8,
         provisioned: Bool,
         connected: Bool,
         rssi: Int8,
         interval: Double = 0.250
    ) {
        self.name = name
        self.uuidString = uuidString
        self.delegate = delegate
        
        self.spec = CBMPeripheralSpec
            .simulatePeripheral(
                identifier: UUID(uuidString: uuidString)!,
                proximity: .near
            )
            .advertising(
                    advertisementData: [
                        CBMAdvertisementDataLocalNameKey    : name,
                        CBMAdvertisementDataServiceUUIDsKey : [CBMUUID.wifi],
                        CBMAdvertisementDataIsConnectable   : true as NSNumber,
                        CBMAdvertisementDataServiceDataKey   : [
                            CBMUUID.wifi : Data([
                                UInt8(version), // Version
                                0x00, // Reserved
                                UInt8(provisioned ? 0x01 : 0x00) | (connected ? 0x02 : 0x00), // Flags
                                UInt8(bitPattern: rssi)  // Wi-Fi RSSI
                            ])
                        ]
                    ],
                    withInterval: interval,
                    alsoWhenConnected: false
            )
            .connectable(
                    name: name,
                    services: [
                        MockWiFiService()
                    ],
                    delegate: delegate,
                    connectionInterval: 0.150,
                    mtu: 23)
            .allowForRetrieval()
            .build()
    }
}
