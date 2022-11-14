//
//  ScannerView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 06/07/2022.
//

import NordicStyle
import SwiftUI
import CoreBluetoothMock

struct ScannerView: View {
    @EnvironmentObject var vmFactory: DeviceViewModelFactory
    @StateObject var viewModel: ScannerViewModel
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .noPermission:
                    Placeholder(
                        text: "Bluetooth permission denied",
                        message: "Please, enable Bluetooth in Settings",
                        image: "bluetooth_disabled",
                        action: {
                            Button(action: {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }) {
                                Text("Open Settings")
                            }
                            .buttonStyle(NordicButtonStyle())
                        }
                    )
                    .padding()
                case .scanning:
                    if viewModel.scanResults.isEmpty {
                        scanningPlaceholder
                    } else {
                        listView()
                    }
                case .waiting:
                    scanningPlaceholder
                case .turnedOff:
                    Placeholder(
                        text: "Bluetooth is turned off",
                        message: "Please, enable Bluetooth in Settings",
                        image: "bluetooth_disabled",
                        action: {
                            Button(action: {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }) {
                                Text("Open Settings")
                            }
                            .buttonStyle(NordicButtonStyle())
                        }
                    )
                }
            }
            .navigationTitle("Scanner")
            .toolbar {
                // Filter Button
                Button(action: {
                    viewModel.onlyUnprovisioned.toggle()
                }) {
                    Image(systemName: viewModel.onlyUnprovisioned
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
            
            Placeholder(text: "Select the device", message: "Select Bluetooth device to start provisioning process", image: "bluetooth")
        }
        .setupNavBarBackground()
        .accentColor(.white)
        .onAppear {
            viewModel.startScan()
        }
        .sheet(isPresented: $viewModel.showStartInfo) {
            IntroView(show: $viewModel.showStartInfo, dontShowAgain: $viewModel.dontShowAgain)
        }
        
    }
    
    @ViewBuilder
    private var scanningPlaceholder: some View {
        Placeholder(
            text: "Scanning for devices",
            message: "If you don't see your device check if it is turned on",
            image: "bluetooth_searching"
        )
        .padding()
    }
    
    @ViewBuilder
    private func listView() -> some View {
        List {
            Section {
                ForEach(viewModel.scanResults, id: \.id) { scanResult in
                    NavigationLink {
                        DeviceView(viewModel: vmFactory.viewModel(for: scanResult.sr.id))
                            .navigationTitle(scanResult.name)
                            
                    } label: {
                        ScanResultRaw(scanResult: scanResult)
                    }
                    .deviceAdoptiveDetail()
                    .accessibilityIdentifier("scan_result_\(viewModel.scanResults.firstIndex(where: { $0.id == scanResult.id }) ?? -1)")
                }
            } header: {
                HStack {
                    Text("Devices")
                    Spacer()
                    ProgressView()
                        .isHidden((viewModel.state != .scanning), remove: true)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

/*
private struct ScanResultLabel: View {
    let scanResult: ScannerViewModel.ScanResult
    
    var body: some View {
        HStack {
            Text(scanResult.name)
                .lineLimit(1)
            if scanResult.previsioned == true {
                Image(systemName: "checkmark")
            }
            
            if scanResult.version != nil {
                Spacer()
                Text("v\(scanResult.version!)")
                    .foregroundColor(.secondary)
            }
        }
    }
}
 */

#if DEBUG
import Provisioner2

struct ScannerView_Previews: PreviewProvider {
    struct MockScanResult: Provisioner2.ScanResult {
        var id: String {
            UUID().uuidString
        }
        
        var name: String
        
        var rssi: Int
        
        var provisioned: Bool
        
        var connected: Bool
        
        var version: Int?
        
        var wifiRSSI: Int?
        
        
    }
    
    class DummyScanViewModel: ScannerViewModel {
        override var showStartInfo: Bool {
            get {
                false
            }
            set {
                
            }
        }
        
        override var state: ScannerViewModel.State {
            .scanning
        }
        
//        override var scanResults: [any T] {
//            return (0...3)
//                .map { i -> any ScannerView_Previews.DummyScanViewModel.T in
//                    MockScanResult(name: "Device \(i)", rssi: -80 + i * 10, provisioned: i % 2 == 0, connected: i == 0)
//                }
//        }
    }
    
    static var previews: some View {
        ScannerView(viewModel: DummyScanViewModel())
            .previewDisplayName("iPhone 14 Pro")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
#endif
