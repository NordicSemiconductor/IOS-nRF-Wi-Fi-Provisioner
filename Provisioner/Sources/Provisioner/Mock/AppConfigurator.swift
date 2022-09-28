//
//  AppConfigurator.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 23/09/2022.
//

import CoreBluetoothMock
import Foundation

#if DEBUG

extension CBMUUID {
    static let version = CBMUUID(string: "14387801-130c-49e7-b877-2881c89cb258")
    static let controlPoint = CBMUUID(string: "14387802-130c-49e7-b877-2881c89cb258")
    static let dataOut = CBMUUID(string: "14387803-130c-49e7-b877-2881c89cb258")
    static let wifi = CBMUUID(string: "14387800-130c-49e7-b877-2881c89cb258")
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
        .simulatePeripheral(proximity: .near)
        .advertising(
                advertisementData: [
                    CBMAdvertisementDataLocalNameKey    : "nRF-Wi-Fi",
                    CBMAdvertisementDataServiceUUIDsKey : [CBMUUID.wifi],
                    CBMAdvertisementDataIsConnectable   : true as NSNumber
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
        .build()

public class AppConfigurator: ObservableObject {
    public static func setup() {
        CBMCentralManagerMock.simulateInitialState(.poweredOff)
        CBMCentralManagerMock.simulatePeripherals([
            wifiDevice
        ])
        CBMCentralManagerMock.simulatePowerOn()
    }
}
#else
public class AppConfigurator: ObservableObject {
    public static func setup() {
        
    }
}
#endif
