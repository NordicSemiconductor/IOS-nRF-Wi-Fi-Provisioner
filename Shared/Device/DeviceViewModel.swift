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
	enum State {
		case connecting
		case failed(ReadableError)
		case connected
	}

	enum WiFiStatus {
		case connected, notConnected
	}
    
    enum Error: ReadableError {
        case peripheralNotFound
        case canNotConnect
        case serviceNotFound
        
        var title: String? {
            switch self {
            case .peripheralNotFound:
                return "Peripheral not found"
            case .canNotConnect:
                return "Connection failed"
            case .serviceNotFound:
                return "Service not found"
            }
        }
        
        var message: String {
            switch self {
            case .peripheralNotFound:
                return "Peripheral can not be found"
            case .canNotConnect:
                return "Can not connect the peripheral"
            case .serviceNotFound:
                return "Wi-Fi service not found"
            }
        }
        
        
    }

	let peripheralId: UUID
    
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

    @Published private(set) var state: State = .connecting

	@Published private(set) var wifiState: WiFiStatus? = nil
	@Published private(set) var versien: String? = nil

    private let centralManager: CentralManager

	init(peripheralId: UUID, centralManager: CentralManager = CentralManager()) {
		self.peripheralId = peripheralId
		self.centralManager = centralManager
	}

	func connect() async throws {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [peripheralId]).first else {
            try rethrowError(Error.peripheralNotFound)
        }
        
        do {
            try await centralManager.connect(peripheral)
        } catch {
            try rethrowError(Error.canNotConnect)
        }
        
        // Discover WiFi service
        do {
            try await peripheral.discoverServices([Provisioner.WiFi_Provision_Service])
            guard let wifiService = peripheral.discoveredServices?.first(where: {
                $0.identifier == Provisioner.WiFi_Provision_Service
            }) else {
                throw Error.serviceNotFound
            }
            
            print("WIFI service found: \(wifiService.identifier)")
        } catch {
            try await centralManager.cancelPeripheralConnection(peripheral)
            try rethrowError(Error.serviceNotFound)
        }
        
        DispatchQueue.main.async {
            self.state = .connected
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
