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

/// Queue structure based on LinkedList.
private struct Queue<Element> {
    private var head: Node<Element>?
    private var tail: Node<Element>?

    private class Node<Element> {
        var value: Element
        var next: Node?

        init(value: Element) {
            self.value = value
        }
    }

    /// Adds a new element to the end of the queue.
    ///
    /// - Parameter value: The value to add.
    mutating func enqueue(_ value: Element) {
        let node = Node(value: value)
        if head == nil {
            head = node
            tail = node
        } else {
            tail?.next = node
            tail = node
        }
    }

    /// Removes the first element from the queue.
    ///
    /// - Returns: The removed element.
    mutating func dequeue() -> Element? {
        guard let head = head else { return nil }
        self.head = head.next
        return head.value
    }

    /// Returns the first element of the queue.
    ///
    /// - Returns: The first element of the queue.
    func peek() -> Element? {
        return head?.value
    }

    /// Returns the number of elements in the queue.
    ///
    /// - Returns: The number of elements in the queue.
    func count() -> Int {
        guard let head = head else { return 0 }
        var count = 1
        var node = head
        while let next = node.next {
            count += 1
            node = next
        }
        return count
    }
}

private class WifiDeviceDelegate: CBMPeripheralSpecDelegate {
    var controlPointQueue = Queue<Request>()

    init() { }

    deinit {
        print("WifiDeviceDelegate deinit")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveIncludedServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?, for service: CBMServiceMock) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveIncludedServiceDiscoveryRequest:for:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveIncludedServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?, for service: CBMService) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveIncludedServiceDiscoveryRequest:for:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveDescriptorsDiscoveryRequestFor characteristic: CBMCharacteristicMock) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveDescriptorsDiscoveryRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveDescriptorsDiscoveryRequestFor characteristic: CBMCharacteristic) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveDescriptorsDiscoveryRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor descriptor: CBMDescriptorMock) -> Swift.Result<Data, Error> {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor descriptor: CBMDescriptor) -> Swift.Result<Data, Error> {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteCommandFor characteristic: CBMCharacteristicMock, data: Data) {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteCommandFor characteristic: CBMCharacteristic, data: Data) {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor descriptor: CBMDescriptorMock, data: Data) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveWriteRequestFor:data:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor descriptor: CBMDescriptor, data: Data) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveWriteRequestFor:data:) has not been implemented")
    }

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

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor characteristic: CBMCharacteristic) -> Swift.Result<Data, Error> {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristicMock, data: Data) -> Swift.Result<(), Error> {
        do {
            let request = try! Request(serializedData: data)
            let command = request.opCode
            switch command {
            case .getStatus:
                peripheral.simulateValueUpdate(wifiStatus, for: .controlPoint)
                return Swift.Result.success(())
            default:
                fatalError("OpCode not implemented")
            }
        } catch {
            return Swift.Result.failure(error)
        }
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristic, data: Data) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveWriteRequestFor:data:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristicMock) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristic) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveSetNotifyRequest:for:) has not been implemented")
    }
}

extension WifiDeviceDelegate {
    var versionData: Swift.Result<Data, Error> {
        var info = Info()
        info.version = 17
        let data = try! info.serializedData()
        return Swift.Result.success(data)
    }

    var wifiStatus: Data{
        var response = Response()
        response.status = .success
        var deviceStatus = DeviceStatus()
        deviceStatus.state = ConnectionState.connected
        response.deviceStatus = deviceStatus
        return try! response.serializedData()
    }
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
