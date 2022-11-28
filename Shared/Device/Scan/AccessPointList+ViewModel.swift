//
// Created by Nick Kibysh on 04/09/2022.
//

import Combine
import Foundation
import Provisioner2
import os

extension AccessPointList {
    @MainActor
    class ViewModel: ObservableObject {
        struct ScanResult: Hashable, Identifiable {
            let wifi: WifiInfo
            let rssi: Int?
            
            var id: String {
                wifi.bssid.description + (rssi.map { "\($0)" } ?? "")
            }
            
            static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
                lhs.wifi.bssid == rhs.wifi.bssid
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(wifi.bssid)
            }
        }
        
        deinit {
            try? provisioner.stopScan()
        }
        
        init() {
            
        }
        
        private let logger = Logger(subsystem: String(describing: ViewModel.self), category: "AccessPointListViewModel")
        private var cancellables = Set<AnyCancellable>()
        // MARK: - Constants
        var provisioner: Provisioner!
        var accessPointSelection: AccessPointSelection!
        
        // MARK: - Properties
        @Published(initialValue: []) var accessPoints: [ScanResult]
        @Published(initialValue: false) var isScanning: Bool
        
        @Published(initialValue: nil) var selectedAccessPointId: String? {
            didSet {
                guard let apId = selectedAccessPointId else { return }
                self.selectedAccessPoint = allAccessPoints.first(where: { $0.id == apId })?.wifi
            }
        }
        
        @Published(initialValue: nil) var selectedAccessPoint: WifiInfo? {
            didSet {
                guard let ap = selectedAccessPoint else {
                    return
                }
                accessPointSelection.selectedWiFi = ap
                accessPointSelection.showAccessPointList = false
            }
        }
        
        @Published(initialValue: false) var showError: Bool
        var error: ReadableError? {
            didSet {
                if error != nil {
                    showError = true
                }
            }
        }
        
        // MARK: - Private Properties
        private var allAccessPoints: Set<ScanResult> = [] {
            didSet {
                var aps: [ScanResult] = []
                for ap in allAccessPoints {
                    if let existing = aps.firstIndex(where: { $0.wifi.ssid == ap.wifi.ssid }) {
                        if aps[existing].rssi < ap.rssi {
                            aps[existing] = ap
                        }
                    } else {
                        aps.append(ap)
                    }
                }
                
                self.logger.debug("Assigned access points: \(self.allAccessPoints.count)")
                self.accessPoints = aps.sorted(by: { $0.wifi.ssid < $1.wifi.ssid })
            }
        }
        
        init(provisioner: Provisioner, accessPointSelection: AccessPointSelection) {
            self.provisioner = provisioner
            self.accessPointSelection = accessPointSelection
        }
        
        func setupAndScan(provisioner: Provisioner, scanDelegate: ProvisionerScanDelegate, wifiSelection: AccessPointSelection) {
            self.provisioner = provisioner
            self.provisioner.provisionerScanDelegate = scanDelegate
            self.accessPointSelection = wifiSelection
            self.startScan()
        }
        
        func allChannels(for accessPoint: WifiInfo) -> [ScanResult] {
            let array = Array(allAccessPoints)
                .filter { $0.wifi.ssid == accessPoint.ssid }
                .sorted { $0.rssi > $1.rssi }
            return array
        }
        
        func startScan() {
            try! provisioner.startScan(scanParams: ScanParams())
        }
        
    }
}

extension AccessPointList.ViewModel: ProvisionerScanDelegate {
    func provisioner(_ provisioner: Provisioner2.Provisioner, discoveredAccessPoint wifi: Provisioner2.WifiInfo, rssi: Int?) {
        let scanResult = ScanResult(wifi: wifi, rssi: rssi)
        allAccessPoints.insert(scanResult)
    }
    
    func pravisionerDidStartScan(_ provisioner: Provisioner2.Provisioner, error: Error?) {
        if let error {
            self.error = TitleMessageError(error: error)
        }
    }
    
    func pravisionerDidStopScan(_ provisioner: Provisioner2.Provisioner, error: Error?) {
        if let error {
            self.error = TitleMessageError(error: error)
        }
    }
}
