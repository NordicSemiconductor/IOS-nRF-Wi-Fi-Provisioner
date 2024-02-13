//
//  ScannerViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Combine
import CoreBluetoothMock
import Foundation
import NordicWiFiProvisioner_BLE
import SwiftUI
import os

extension ScannerViewModel {
    enum State {
        case waiting, scanning, noPermission, turnedOff
    }
    
    struct DisplayableScanResult: Identifiable, Equatable, Hashable {
        let id: String
        var name: String { sr.name }
        var rssi: Int { sr.rssi }
        var provisioned: Bool { sr.provisioned }
        var connected: Bool { sr.connected }
        var version: Int? { sr.version }
        var wifiRSSI: Int? { sr.wifiRSSI }
        
        let sr: NordicWiFiProvisioner_BLE.ScanResult
        
        init(rowScanResult: NordicWiFiProvisioner_BLE.ScanResult) {
            self.sr = rowScanResult
            self.id = sr.id.uuidString + sr.name + "\(sr.rssi)" + "\(sr.provisioned)" + "\(sr.connected)" + "\(sr.wifiRSSI ?? 0)"
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
    @Published private(set) var scanResults: [DisplayableScanResult] = []
    
    private let scanner: NordicWiFiProvisioner_BLE.Scanner
    
    private var cancelable: Set<AnyCancellable> = []
    
    init(scanner: NordicWiFiProvisioner_BLE.Scanner = Scanner()) {
        self.scanner = scanner
        self.showStartInfo = !dontShowAgain
        
        self.scanner.delegate = self
        self.startScan()
    }
    
    func startScan() {
        self.scanner.startScan()
    }
    
    private func reset() {
        self.scanResults.removeAll()
    }
}

extension ScannerViewModel.State {
    init(from bluetoothState: NordicWiFiProvisioner_BLE.Scanner.State) {
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


extension ScannerViewModel: NordicWiFiProvisioner_BLE.ScannerDelegate {
    func scannerDidUpdateState(_ state: NordicWiFiProvisioner_BLE.Scanner.State) {
        self.state = State.init(from: state)
    }
    
    func scannerDidDiscover(_ scanResult: NordicWiFiProvisioner_BLE.ScanResult) {
        if let index = scanResults.firstIndex(where: { $0.sr.id == scanResult.id }) {
            scanResults[index] = DisplayableScanResult(rowScanResult: scanResult)
        } else {
            scanResults.append(DisplayableScanResult(rowScanResult: scanResult))
            
            scanResults
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

