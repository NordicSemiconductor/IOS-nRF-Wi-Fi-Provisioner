//
// Created by Nick Kibysh on 04/09/2022.
//

import Combine
import Foundation
import NordicWiFiProvisioner_BLE
import iOS_Common_Libraries

// MARK: - AccessPointList.ViewModel

extension AccessPointList {
    
    @MainActor
    class ViewModel: ObservableObject {
        struct ScanResult: Hashable, Identifiable {
            let wifi: WifiInfo
            let rssi: Int?
            
            var id: String {
                wifi.bssid.description + "\(wifi.channel)"
            }
            
            static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
                lhs.wifi.bssid == rhs.wifi.bssid
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(wifi.bssid)
                hasher.combine(wifi.channel)
            }
        }
        
        // MARK: Init
        
        init() {}
        
        init(provisioner: DeviceManager) {
            self.provisioner = provisioner
        }
        
        deinit {
            try? provisioner.stopScan()
        }
        
        // MARK: Properties
        
        private let logger = NordicLog(ViewModel.self, subsystem: Bundle.main.bundleIdentifier!)
        private var cancellables = Set<AnyCancellable>()
        
        var provisioner: DeviceManager!
        
        @Published(initialValue: []) var accessPoints: [ScanResult]
        @Published(initialValue: false) var isScanning: Bool
        
        @Published(initialValue: nil) var selectedAccessPoint: WifiInfo?
        
        @Published(initialValue: false) var showError: Bool
        var error: ReadableError? {
            didSet {
                if error != nil {
                    showError = true
                }
            }
        }
        
        func setupAndScan(provisioner: DeviceManager) {
            self.provisioner = provisioner
            self.provisioner.wiFiScanerDelegate = self
            self.startScan()
        }
        
        func startScan() {
            try! provisioner.startScan(scanParams: ScanParams())
        }
    }
}

// MARK: - WiFiScanerDelegate

extension AccessPointList.ViewModel: WiFiScanerDelegate {
    func deviceManager(_ provisioner: NordicWiFiProvisioner_BLE.DeviceManager, discoveredAccessPoint wifi: NordicWiFiProvisioner_BLE.WifiInfo, rssi: Int?) {
        let scanResult = ScanResult(wifi: wifi, rssi: rssi)
        accessPoints.append(scanResult)
    }
    
    func deviceManagerDidStartScan(_ provisioner: NordicWiFiProvisioner_BLE.DeviceManager, error: Error?) {
        if let error {
            self.error = TitleMessageError(error: error)
        }
    }
    
    func deviceManagerDidStopScan(_ provisioner: NordicWiFiProvisioner_BLE.DeviceManager, error: Error?) {
        if let error {
            self.error = TitleMessageError(error: error)
        }
    }
}
