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
        case canNotConnect
        case serviceNotFound
        
        var title: String? {
            switch self {
            case .canNotConnect:
                return "Connection failed"
            case .serviceNotFound:
                return "Wi-Fi Service not found"
            }
        }
        
        var message: String {
            switch self {
            case .canNotConnect:
                return "Can not connect the peripheral"
            case .serviceNotFound:
                return "You can not provision this device as there's no Wi-Fi service found."
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
    
    let provisioner: Provisioner

	init(peripheralId: UUID, centralManager: CentralManager = CentralManager()) {
		self.peripheralId = peripheralId
        self.provisioner = Provisioner(deviceID: peripheralId)
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
            case .dataOutCharacteristicNotFoind:
                fallthrough
            case .wifiServiceNotFound:
                try rethrowError(Error.serviceNotFound)
            }
        } catch {
            try rethrowError(Error.canNotConnect)
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
