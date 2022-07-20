//
//  ScannerViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Foundation
import nRF_BLE
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
    
    private let scanner: nRF_BLE.Scanner
    
    init(scanner: nRF_BLE.Scanner = nRF_BLE.Scanner()) {
        self.scanner = scanner
    }
    
    func startScan() {
        Task {
            do {
                try await scanner.getReady()
                
                let scanResultStream = try await scanner.scanForPeripherals(
                    withServices: uuidFilter
                    ? UUID(uuidString: Provisioner.WiFi_Provision_Service).map { [$0] }
                        : nil
                )
                
                for try await scanResult in scanResultStream {
                    if self.nameFilter, case .none = scanResult.name {
                        return
                    }
                    
                    if self.nearbyFilter, !scanResult.rssi.isNearby {
                        return
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }

                        self.scanResults.insertIfNotContains(
                            ScanResult(
                                name: scanResult.name ?? "n/a",
                                id: scanResult.id,
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
            await scanner.stopScan()
            DispatchQueue.main.async { [weak self] in
                self?.scanResults.removeAll()
            }
            startScan()
        }
    }
}
