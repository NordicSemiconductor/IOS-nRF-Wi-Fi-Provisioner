//
//  ScannerViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Foundation
import nRF_BLE

class ScannerViewModel: ObservableObject {
    enum State {
        case waiting, scanning, noPermission, turnedOff
    }
    
    @Published private (set) var state: State = .waiting
    @Published private (set) var scanResults: [ScanResult] = []
    
    @Published var uuidFilter = false {
        didSet {
            scanResults.removeAll()
        }
    }
    @Published var nearbyFilter = false {
        didSet {
            scanResults.removeAll()
        }
    }
    @Published var nameFilter = false {
        didSet {
            scanResults.removeAll()
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
                let scanResultStream = try await scanner.scanForPeripherals(withServices: nil)
                
                for try await scanResult in scanResultStream {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        if self.nameFilter, case .none = scanResult.name {
                            return
                        }
                        
                        if self.nearbyFilter, !scanResult.rssi.isNearby {
                            return 
                        }

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
}
