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
    
    // MARK: Init
    
    init(provisioner: DeviceManager) {
        self.provisioner = provisioner
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
                            APWiFiScanView(wiFiScan: accessPoint, selected: viewModel.selectedAccessPoint == accessPoint.wifi)
                                .onTapGesture {
                                    viewModel.selectedAccessPoint = accessPoint.wifi
                                    presentationMode.wrappedValue.dismiss()
                                }
                                .tag(accessPoint.wifi)
                        }
                    }
                }
                .accessibilityIdentifier("access_point_list")
            }
        }
        .navigationTitle("Wi-Fi")
        .onFirstAppear {
            viewModel.setupAndScan(provisioner: provisioner)
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
        override func setupAndScan(provisioner: DeviceManager) {
            self.provisioner = MockScanProvisioner(deviceId: UUID())
            self.provisioner.wiFiScanerDelegate = self
            try? self.provisioner.startScan(scanParams: ScanParams())
        }
    }
    
    static var previews: some View {
        NavigationView {
            AccessPointList(
                provisioner: MockScanProvisioner(deviceId: UUID())
            )
        }
    }
}
#endif
