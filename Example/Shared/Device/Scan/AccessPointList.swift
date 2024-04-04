//
//  AccessPointList.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 26/07/2022.
//

import SwiftUI
import iOS_Common_Libraries
import NordicWiFiProvisioner_BLE

// MARK: - AccessPointList

struct AccessPointList: View {
    
    // MARK: Properties
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ViewModel()
    
    let provisioner: DeviceManager
    let wifiSelection: AccessPointSelection
    
    // MARK: Init
    
    init(provisioner: DeviceManager, wifiSelection: AccessPointSelection) {
        self.provisioner = provisioner
        self.wifiSelection = wifiSelection
    }
    
    // MARK: View
    
    var body: some View {
        VStack {
            if viewModel.accessPoints.isEmpty {
                Placeholder(text: "Scanning", message: "Scanning for Wi-Fi", systemImage: "wifi")
            } else {
                List {
                    Section("Access Points") {
                        ForEach(viewModel.accessPoints) { accessPoint in
                            HStack {
                                Label(accessPoint.wifi.ssid, systemImage: accessPoint.wifi.isOpen ? "lock.open" : "lock")
                                    .tint(Color.accentColor)
                                
                                Spacer()
                                
                                accessPoint.rssi.map {
                                    RSSIView(rssi: RSSI(wifiLevel: $0))
                                        .frame(maxWidth: 30, maxHeight: 20)
                                }
                            }
                        }
                    }
                }
                .accessibilityIdentifier("access_point_list")
            }
        }
        .navigationTitle("Wi-Fi")
        .onFirstAppear {
            viewModel.setupAndScan(provisioner: provisioner, wifiSelection: wifiSelection)
        }
        .toolbar {
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .alert(viewModel.error?.title ?? "Error", isPresented: $viewModel.showError) {
            Button("Cancel", role: .cancel) {
                // No-op.
            }
        } message: {
            if let message = viewModel.error?.message {
                Text(message)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AccessPointList_Previews: PreviewProvider {
    struct Selection: AccessPointSelection {
        var selectedWiFi: NordicWiFiProvisioner_BLE.WifiInfo?
        
        var showAccessPointList: Bool = false
    }
    
    class MockScanProvisioner: DeviceManager {
        typealias SR = AccessPointList.ViewModel.ScanResult
        override func startScan(scanParams: ScanParams) throws {
            let scanResults = [
                SR(wifi: .wifi1, rssi: -40),
                SR(wifi: .wifi2, rssi: -60),
                SR(wifi: .wifi3, rssi: -80),
                SR(wifi: .wifi4, rssi: -100),
            ]
            
            for sr in scanResults {
                self.wiFiScanerDelegate?.deviceManager(DeviceManager(deviceId: UUID()), discoveredAccessPoint: sr.wifi, rssi: sr.rssi)
            }
        }
    }
    
    class DummyAccessPointListViewModel: AccessPointList.ViewModel {
        override func setupAndScan(provisioner: DeviceManager, wifiSelection: AccessPointSelection) {
            self.provisioner = MockScanProvisioner(deviceId: UUID())
            self.provisioner.wiFiScanerDelegate = self
            try? self.provisioner.startScan(scanParams: ScanParams())
        }
    }
    
    static var previews: some View {
        NavigationView {
            AccessPointList(
                provisioner: MockScanProvisioner(deviceId: UUID()),
                wifiSelection: Selection()
            )
        }
    }
}
#endif
