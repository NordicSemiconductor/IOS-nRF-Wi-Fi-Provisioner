//
//  ScannerViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import AsyncBluetooth
import Foundation
import Provisioner
import SwiftUI

class ScannerViewModel: ObservableObject {
    enum State {
        case waiting, scanning, noPermission, turnedOff
    }

    // Show start info on first launch
    @AppStorage("dontShowAgain") var dontShowAgain: Bool = false
    @Published var showStartInfo: Bool = false
    
    @Published private (set) var state: State = .waiting
    @Published private (set) var scanResults: [ScanResult] = []
    private var allScanResults: [ScanData] = []
    
    @Published var uuidFilter = true {
        didSet {
            reset()
        }
    }
    @Published var nearbyFilter = false {
        didSet {
            reset()
        }
    }
    @Published var nameFilter = true {
        didSet {
            reset()
        }
    }
    
    private let scanner: CentralManager
    
    init(scanner: CentralManager = CentralManager()) {
        self.scanner = scanner
        showStartInfo = !dontShowAgain
    }
    
    func startScan() {
        Task {
            do {
                try await scanner.waitUntilReady()
                
                let scanResultStream = try await scanner.scanForPeripherals(withServices: nil)
                
                DispatchQueue.main.async { [weak self] in
                    self?.state = .scanning
                }
                
                for try await scanResult in scanResultStream {
                    self.allScanResults.appendIfNotContains(scanResult)
                    
                    DispatchQueue.main.async {
                        self.scanResults = self.allScanResults.filter { sr in
                            if self.nameFilter && sr.peripheral.name?.isEmpty != false {
                                return false
                            }
                            
                            if self.nearbyFilter && !BluetoothRSSI(level: sr.rssi.intValue).isNearby {
                                return false
                            }
                            
                            if self.uuidFilter && !sr.containsService(Provisioner.Service.wifi) {
                                return false
                            }
                            
                            return true
                        }
                        .map {
                            ScanResult(name: $0.peripheral.name ?? "n/a", id: $0.peripheral.identifier, rssi: $0.rssi.intValue)
                        }
                    }
                }
            } catch let e {
                print(e.localizedDescription)
            }
            
        }
    }
    
    private func reset() {
        Task {
            DispatchQueue.main.async { [weak self] in
                self?.state = .waiting
            }
            await scanner.stopScan()
            DispatchQueue.main.async { [weak self] in
                self?.scanResults.removeAll()
            }
            startScan()
        }
    }
}
