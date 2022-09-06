//
//  ScannerViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Combine
import Foundation
import Provisioner
import SwiftUI
import CoreBluetoothMock

extension ScannerViewModel {
    enum State {
        case waiting, scanning, noPermission, turnedOff
    }

    struct ScanResult: Identifiable, Equatable {
        let name: String
        let rssi: Int
        let id: UUID
    }
}

class ScannerViewModel: ObservableObject {
    // Show start info on first launch
    @AppStorage("dontShowAgain") var dontShowAgain: Bool = false
    @Published var showStartInfo: Bool = false
    @Published var onlyUnprovisioned: Bool = false
    
    @Published private (set) var state: State = .waiting
    @Published private (set) var scanResults: [ScanResult] = []
    private var allScanResults: [BluetoothManager.ScanResult] = [] {
        didSet {
            scanResults = allScanResults.map {
                ScannerViewModel.ScanResult(
                        name: $0.name,
                        rssi: $0.rssi,
                        id: $0.peripheral.identifier
                )
            }
        }
    }

    private let bluetoothManager: BluetoothManager

    private var cancelable: Set<AnyCancellable> = []
    
    init(bluetoothManager: BluetoothManager = BluetoothManager()) {
        self.bluetoothManager = bluetoothManager
        showStartInfo = !dontShowAgain

        bluetoothManager.statePublisher
            .receive(on: DispatchQueue.main)
            .mapError { _ in fatalError() }
            .sink(receiveValue: { [weak self] state in
                guard let self = self else { return }
                self.state = State(from: state)
            })
            .store(in: &cancelable)

    }

    func startScan() {
        bluetoothManager.peripheralPublisher
            .receive(on: DispatchQueue.main)
            .mapError { _ in fatalError() }
                .sink(receiveValue: { [weak self] result in
                    guard let self = self else { return }
                    if !self.allScanResults.contains(result) {
                        self.allScanResults.append(result)
                    }
            })
            .store(in: &cancelable)
    }
    
    private func reset() {
        // TODO: reset scan results when filter is applied
    }
}

extension ScannerViewModel.State {
    init(from bluetoothState: CBManagerState) {
        switch bluetoothState {
        case .poweredOn:
            self = .scanning
        case .poweredOff:
            self = .turnedOff
        case .unauthorized:
            self = .noPermission
        case .unsupported:
            self = .noPermission
        case .unknown:
            self = .waiting
        case .resetting:
            self = .waiting
        }
    }
}
