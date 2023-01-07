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
                        DeviceView(viewModel: vmFactory.viewModel(for: scanResult.sr.id.uuidString))
                            .navigationTitle(scanResult.name)
                            
                    } label: {
                        ScanResultRaw(scanResult: scanResult.sr)
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

#if DEBUG
import NordicWiFiProvisioner

struct ScannerView_Previews: PreviewProvider {
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
    }
    
    static var previews: some View {
        ScannerView(viewModel: DummyScanViewModel())
            .previewDisplayName("iPhone 14 Pro")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
//            .tint(.nordicBlue)
    }
}
#endif
