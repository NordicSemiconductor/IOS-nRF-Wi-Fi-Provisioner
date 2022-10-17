//
//  ScannerViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Combine
import CoreBluetoothMock
import Foundation
import Provisioner2
import SwiftUI
import os

extension ScannerViewModel {
    enum State {
        case waiting, scanning, noPermission, turnedOff
    }
    
    struct DisplayableScanResult: Provisioner2.ScanResult, Identifiable, Equatable, Hashable {
        let id: String
        var name: String { sr.name }
        var rssi: Int { sr.rssi }
        var provisioned: Bool { sr.provisioned }
        var connected: Bool { sr.connected }
        var version: Int? { sr.version }
        var wifiRSSI: Int? { sr.wifiRSSI }
        
        let sr: Provisioner2.ScanResult
        
        init(rowScanResult: Provisioner2.ScanResult) {
            self.sr = rowScanResult
            self.id = sr.id + sr.name + "\(sr.rssi)" + "\(sr.provisioned)" + "\(sr.connected)" + "\(sr.wifiRSSI ?? 0)"
        }
        
        static func == (lhs: ScannerViewModel.DisplayableScanResult, rhs: ScannerViewModel.DisplayableScanResult) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
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
    
    @Published private(set) var state: State = .waiting
    @Published private(set) var scanResults: [Provisioner2.ScanResult] = []
    
    private let scanner: Provisioner2.Scanner
    
    private var cancelable: Set<AnyCancellable> = []
    
    init(scanner: Provisioner2.Scanner = Scanner()) {
        self.scanner = scanner
        self.showStartInfo = !dontShowAgain
        
        self.scanner.delegate = self
        self.startScan()
        // TODO: Handle State Changing
        /*
        bluetoothManager.statePublisher
            .receive(on: DispatchQueue.main)
            .mapError { _ in fatalError() }
            .sink(receiveValue: { [weak self] state in
                guard let self = self else { return }
                self.state = State(from: state)
            })
            .store(in: &cancelable)
         */
    }
    
    
    func startScan() {
        self.scanner.startScan()
        // TODO: Handle Start Scar
        /*
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
         */
    }
    
    private func reset() {
        // TODO: Handle Reset
        /*
        scanResults = allScanResults.filter {
            onlyUnprovisioned ? $0.previsioned != true : true
        }.map {
            ScannerViewModel.ScanResult(
                name: $0.name,
                rssi: $0.rssi,
                id: $0.peripheral.identifier,
                previsioned: $0.previsioned,
                version: $0.version
            )
        }
         */
    }
}

extension ScannerViewModel.State {
    init(from bluetoothState: Provisioner2.Scanner.State) {
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


extension ScannerViewModel: Provisioner2.ScannerDelegate {
    func scannerDidUpdateState(_ state: Provisioner2.Scanner.State) {
        self.state = State.init(from: state)
    }
    
    func scannerDidDiscover(_ scanResult: Provisioner2.ScanResult) {
        if let index = scanResults.firstIndex(where: { ($0 as? DisplayableScanResult)?.sr.id == scanResult.id }) {
            scanResults[index] = DisplayableScanResult(rowScanResult: scanResult)
        } else {
            scanResults.append(DisplayableScanResult(rowScanResult: scanResult))
            
            scanResults
                .compactMap { $0 as! DisplayableScanResult }
                .forEach { dsr in
                    print(dsr.sr.id)
                }
            
        }
    }
    
    func scannerStartedScanning() {
        
    }
    
    func scannerStoppedScanning() {
        
    }
}

