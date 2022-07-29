//
//  DeviceViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import AsyncBluetooth
import Foundation
import Provisioner

class DeviceViewModel: ObservableObject {
    enum State: CustomStringConvertible {
        var description: String {
            switch self {
                
            case .connecting:
                return "Connecting ..."
            case .failed(let e):
                return e.message
            case .connected:
                return "Connected"
            }
        }
        
		case connecting
		case failed(ReadableError)
		case connected
	}

	enum WiFiStatus {
		case connected, notConnected
	}
    
    enum Error: ReadableError {
        case canNotConnect
        case serviceNotFound
        case noResponse
        case canNotStopScan
        
        var title: String? {
            switch self {
            case .canNotConnect:
                return "Connection failed"
            case .serviceNotFound:
                return "Wi-Fi Service not found"
            case .noResponse:
                return "No response"
            case .canNotStopScan:
                return "Can not stop scanning"
            }
        }
        
        var message: String {
            switch self {
            case .canNotConnect:
                return "Can not connect the peripheral"
            case .serviceNotFound:
                return "You can not provision this device as there's no Wi-Fi service found."
            case .noResponse:
                return "Can not get response from the device"
            case .canNotStopScan:
                return "Can not stop scanning"
            }
        }
        
        
    }

	let peripheralId: UUID
    
    @Published private (set) var deviceName: String = ""
    
    @Published fileprivate(set) var error: ReadableError? {
        didSet {
            errorTitle = error?.title
            errorMessage = error?.message
            showErrorAlert = true
            error.map { self.state = .failed($0) }
        }
    }
    @Published private(set) var errorTitle: String?
    @Published private(set) var errorMessage: String?
    
    @Published var showErrorAlert: Bool = false
    @Published var showAccessPointList: Bool = false

    @Published private(set) var state: State = .connecting

	@Published private(set) var wifiState: WiFiStatus? = nil
	@Published private(set) var versien: String = "Unknown"
    
    @Published private(set) var accessPoints: [AccessPoint] = []
    @Published var selectedAccessPoint: AccessPoint? {
        didSet {
            self.passwordRequired = self.selectedAccessPoint != nil
        }
    }
    @Published var activeScan = false {
        didSet {
            if activeScan {
                Task {
                    await startScan()
                }
            } else {
                Task {
                    try? await stopScan()
                }
            }
        }
    }
    @Published private(set) var passwordRequired: Bool = false
    @Published var password: String = ""
    
    let provisioner: Provisioner

	init(peripheralId: UUID, centralManager: CentralManager = CentralManager()) {
		self.peripheralId = peripheralId
        self.provisioner = Provisioner(deviceID: peripheralId)
        
        self.deviceName = CentralManager().retrievePeripherals(withIdentifiers: [self.peripheralId]).first?.name ?? "Prov"
	}

	func connect() async throws {
        do {
            try await self.provisioner.connect()
            DispatchQueue.main.async {
                self.state = .connected
            }
        } catch let e as Provisioner.Error {
            switch e {
            case .canNotConnect:
                try rethrowError(Error.canNotConnect)
            case .versionCharacteristicNotFound:
                fallthrough
            case .controlCharacteristicPointNotFound:
                fallthrough
            case .dataOutCharacteristicNotFound:
                fallthrough
            case .wifiServiceNotFound:
                try rethrowError(Error.serviceNotFound)
            case .noResponse:
                try rethrowError(Error.noResponse)
            case .unknownDeviceStatus:
                fatalError()
            }
        } catch {
            try rethrowError(Error.canNotConnect)
        }
	}
    
    func readInformation() async throws {
        let v = try await provisioner.readVersion() ?? "Unknown"
        DispatchQueue.main.async {
            self.versien = v
        }
        
        let status = try await provisioner.getStatus()
        
        DispatchQueue.main.async {
            switch status {
            case .disconnected, .authentication, .association, .obtainingIp:
                self.state = .connecting
            case .connected:
                self.state = .connected
            case .connectionFailed(_):
                self.state = .failed(Error.canNotConnect)
            }
        }
    }
    
    func startScan() async {
        DispatchQueue.main.async {
            self.accessPoints.removeAll()
        }
        do {
            for try await scanResult in try await provisioner.startScan().values {
                print(scanResult.name)
                DispatchQueue.main.async {
                    self.accessPoints.append(scanResult)                    
                }
            }
        } catch let e {
            print(e.localizedDescription)
        }
    }
    
    func stopScan() async throws {
        do {
            try await provisioner.stopScan()
        } catch {
            try rethrowError(Error.canNotStopScan)
        }
    }
    
    private func rethrowError(_ error: ReadableError) throws -> Never {
        DispatchQueue.main.async {
            self.error = error
        }
        throw error
    }

}

#if DEBUG
class MockDeviceViewModel: DeviceViewModel {
    var i: Int? = 0
    
    override var state: DeviceViewModel.State {
        guard let index = i else {
            return .connected
        }
        let states: [State] = [.connecting, .connected, .failed(TitleMessageError(message: "Failed to retreive required services"))]
        
        return states[index % 3]
    }
    
    init(index: Int) {
        super.init(peripheralId: UUID())
        self.i = index
    }
    
    override init(peripheralId: UUID, centralManager: CentralManager = CentralManager()) {
        super.init(peripheralId: peripheralId, centralManager: centralManager)
    }
    
    override func connect() async throws {
        self.error = Error.canNotConnect
        throw Error.canNotConnect
    }
}
#endif
