//
//  ScannerView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 06/07/2022.
//

import SwiftUI
import CoreBluetoothMock

// MARK: - ScannerView

struct ScannerView: View {
    
    // MARK: Properties
    
    @EnvironmentObject var vmFactory: DeviceViewModelFactory
    @StateObject var viewModel: ScannerViewModel
    
    // MARK: view
    
    var body: some View {
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
                    }
                )
                .padding()
            case .waiting, .scanning:
                listView()
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
                    }
                )
            }
        }
        .navigationTitle("Scanner")
        .onAppear {
            viewModel.startScan()
        }
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
                        ScanResultRaw(scanResult.sr)
                    }
                    .deviceAdoptiveDetail()
                }
            } header: {
                LabeledContent {
                    ProgressView()
                        .isHidden((viewModel.state != .scanning), remove: true)
                } label: {
                    Text("Devices")
                        .font(.caption)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
