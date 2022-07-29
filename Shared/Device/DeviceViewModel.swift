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
    // MARK: - Error
    @Published var showErrorAlert: Bool = false
    @Published fileprivate(set) var error: ReadableError? {
        didSet {
            showErrorAlert = true
            error.map { self.state = .failed($0) }
        }
    }
    @Published private (set) var deviceName: String = ""

    @Published fileprivate(set) var state: State = .connecting

	@Published fileprivate(set) var wifiState: WiFiStatus? = nil
	@Published fileprivate(set) var version: String = "Unknown"

    @Published var showAccessPointList: Bool = false
    @Published fileprivate(set) var accessPoints: [AccessPoint] = []
    @Published var selectedAccessPoint: AccessPoint? {
        didSet {
            passwordRequired = selectedAccessPoint?.isOpen == false
        }
    }
    @Published private(set) var passwordRequired: Bool = false
    @Published var password: String = ""
    
    let provisioner: Provisioner
    let peripheralId: UUID

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
}

extension DeviceViewModel {
    func readInformation() async throws {
        let v = try await provisioner.readVersion() ?? "Unknown"
        DispatchQueue.main.async {
            self.version = v
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
}

extension DeviceViewModel {
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
    
    init(index: Int) {
        super.init(peripheralId: UUID())
        self.i = index
        
        let states: [State] = [.connecting, .connected, .failed(TitleMessageError(message: "Failed to retreive required services"))]
        
        self.state = states[index % 3]
    }
    
    override init(peripheralId: UUID, centralManager: CentralManager = CentralManager()) {
        super.init(peripheralId: peripheralId, centralManager: centralManager)
    }
    
    override func connect() async throws {
        if self.i == 2 {
            self.error = Error.canNotConnect
            throw Error.canNotConnect            
        } else {
            await Task {
                self.wifiState = .notConnected
                self.error = nil
                
            }
        }
    }
}
#endif
