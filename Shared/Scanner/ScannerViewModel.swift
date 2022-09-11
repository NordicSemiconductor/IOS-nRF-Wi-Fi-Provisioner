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
import os

extension ScannerViewModel {
    enum State {
        case waiting, scanning, noPermission, turnedOff
    }

    struct ScanResult: Identifiable, Equatable, Hashable {
        let name: String
        let rssi: Int
        let id: UUID
        let previsioned: Bool?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    
}

class ScannerViewModel: ObservableObject {
    let logger = Logger(
            subsystem: Bundle(for: ScannerViewModel.self).bundleIdentifier ?? "",
            category: "scanner.scanner-view-model"
    )
    
    // Show start info on first launch
    @AppStorage("dontShowAgain") var dontShowAgain: Bool = false
    @Published var showStartInfo: Bool = false
    @Published var onlyUnprovisioned: Bool = false {
        didSet {
            reset()
        }
    }
    
    @Published private (set) var state: State = .waiting
    @Published private (set) var scanResults: [ScanResult] = []
    private var allScanResults = Set<BluetoothManager.ScanResult>([]) {
        didSet {
            reset()
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
                        self.allScanResults.insert(result)
                    }
            })
            .store(in: &cancelable)
    }
    
    private func reset() {
        scanResults = allScanResults.filter {
                onlyUnprovisioned ? $0.previsioned != true : true
            }.map {
                ScannerViewModel.ScanResult(
                    name: $0.name,
                    rssi: $0.rssi,
                    id: $0.peripheral.identifier,
                    previsioned: $0.previsioned
                )
            }
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
