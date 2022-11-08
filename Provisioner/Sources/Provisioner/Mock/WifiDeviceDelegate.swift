//
//  File.swift
//  
//
//  Created by Nick Kibysh on 27/09/2022.
//

import Combine
import Foundation
import CoreBluetoothMock
import os

class WifiDeviceDelegate: CBMPeripheralSpecDelegate {
    private var cancellables: Set<AnyCancellable> = Set()
    private let logger = Logger(
            subsystem: Bundle(for: WifiDeviceDelegate.self).bundleIdentifier ?? "",
            category: "wifi-device-delegate"
    )
    
    func peripheralDidReceiveConnectionRequest(_ peripheral: CBMPeripheralSpec) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveCharacteristicsDiscoveryRequest characteristicUUIDs: [CBMUUID]?, for service: CBMServiceMock) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor characteristic: CBMCharacteristicMock) -> Swift.Result<Data, Error> {
        if characteristic.uuid == .version {
            return versionData
        } else {
            fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
        }
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristicMock, data: Data) -> Swift.Result<(), Error> {
        do {
            let request = try! Request(serializedData: data)
            let command = request.opCode
            switch command {
            case .getStatus:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    peripheral.simulateValueUpdate(self.wifiStatus(.disconnected, opCode: command), for: .controlPoint)
                }
                return Swift.Result.success(())
            case .startScan:
                peripheral.simulateValueUpdate(wifiStatus(.disconnected, opCode: command), for: .controlPoint)
                let data = try Data(contentsOf: Bundle.module.url(forResource: "MockAP", withExtension: "json")!)
                let aps = try JSONDecoder().decode([Result].self, from: data)
                
                let iterator = aps.makeIterator().publisher
                let timer = Timer.publish(every: 0.01, on: .main, in: .default)
                    .autoconnect()
                
                Publishers.Zip(iterator, timer)
                    .tryMap { try $0.0.serializedData() }
                    .sink { _ in
                        
                    } receiveValue: {
                        peripheral.simulateValueUpdate($0, for: .dataOut)
                    }
                    .store(in: &cancellables)
                
                return Swift.Result.success(())
            case .stopScan:
                peripheral.simulateValueUpdate(wifiStatus(.connected, opCode: command), for: .controlPoint)
                return Swift.Result.success(())
            case .setConfig:
                peripheral.simulateValueUpdate(wifiStatus(.disconnected, opCode: command), for: .controlPoint)
                
                let states = ConnectionState.allCases
                Publishers.Zip(states.publisher, Timer.publish(every: 0.7, on: .main, in: .default).autoconnect())
                    .map { $0.0 }
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        
                    } receiveValue: { state in
                        peripheral.simulateValueUpdate(
                            try! self.connectionStatusResult(state).serializedData(),
                            for: .dataOut
                        )
                    }
                    .store(in: &cancellables)
                
                return Swift.Result.success(())
            default:
                fatalError("OpCode not implemented")
            }
        } catch {
            return Swift.Result.failure(error)
        }
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristicMock) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }
    
    var versionData: Swift.Result<Data, Error> {
        var info = Info()
        info.version = 17
        let data = try! info.serializedData()
        return Swift.Result.success(data)
    }

    func wifiStatus(_ stt: ConnectionState, opCode: OpCode) -> Data {
        var response = Response()
        response.status = .success
        response.requestOpCode = opCode
        var deviceStatus = DeviceStatus()
        deviceStatus.state = stt
        if let wifiInfo = wifiInfo() {
            deviceStatus.provisioningInfo = wifiInfo
        }
        deviceStatus.scanInfo = scanParam()

        response.deviceStatus = deviceStatus

        return try! response.serializedData()
    }
    
    func connectionStatusResult(_ stt: ConnectionState) -> Result {
        var result = Result()
        result.state = stt
        return result
    }

    func wifiInfo() -> WifiInfo? {
        var wfInfo = WifiInfo()
        wfInfo.ssid = "Nordic Guest".data(using: .utf8)!
        wfInfo.bssid = 0xFA_23_1A_2B_3D_0A.toData()
        wfInfo.channel = 6
        wfInfo.auth = .wpa2Psk
        wfInfo.band = .band5Gh
        return wfInfo
    }
    
    func scanParam() -> ScanParams {
        var sp = ScanParams()
        sp.band = .band5Gh
        sp.groupChannels = 2
        sp.passive = true
        sp.periodMs = 1000
        return sp
    }
}

extension Int {
    func toData() -> Data {
        var value = self
        return Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
    }
}

// MARK: - Children
class NotProvisionedDelegate: WifiDeviceDelegate {
    override func wifiInfo() -> WifiInfo? {
        return nil
    }
}

class ProvisionedNotConnected: WifiDeviceDelegate {
    override func connectionStatusResult(_ stt: ConnectionState) -> Result {
        return super.connectionStatusResult(.disconnected)
    }
}

class ProvisionedConnected: WifiDeviceDelegate {
    
}
