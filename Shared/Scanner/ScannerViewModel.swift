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
                        self?.scanResults.insertIfNotContains(ScanResult(name: scanResult.name ?? "n/a", id: scanResult.id))
                    }
                }
            } catch let e {
                print(e.localizedDescription)
            }
            
        }
    }
}
