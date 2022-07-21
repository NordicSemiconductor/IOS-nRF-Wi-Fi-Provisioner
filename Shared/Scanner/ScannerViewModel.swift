//
//  ScannerViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import AsyncBluetooth
import Foundation
import Provisioner

class ScannerViewModel: ObservableObject {
    enum State {
        case waiting, scanning, noPermission, turnedOff
    }
    
    @Published private (set) var state: State = .waiting
    @Published private (set) var scanResults: [ScanResult] = []
    
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
    }
    
    func startScan() {
        Task {
            do {
                try await scanner.waitUntilReady()
                
                let scanResultStream = try await scanner.scanForPeripherals(
                    withServices: uuidFilter ? [Provisioner.Service.wifi] : nil
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.state = .scanning
                }
                
                for try await scanResult in scanResultStream {
                    if self.nameFilter, case .none = scanResult.peripheral.name {
                        return
                    }
                    
                    if self.nearbyFilter, !scanResult.rssi.isNearby {
                        return
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }

                        self.scanResults.appendIfNotContains(
                            ScanResult(
                                name: scanResult.peripheral.name ?? "n/a",
                                id: scanResult.peripheral.identifier,
                                rssi: scanResult.rssi
                            )
                        )
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
