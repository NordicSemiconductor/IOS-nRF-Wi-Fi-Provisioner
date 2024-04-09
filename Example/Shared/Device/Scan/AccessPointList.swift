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
    @EnvironmentObject private var viewModel: DeviceView.ViewModel
    
    // MARK: View
    
    var body: some View {
        VStack {
            if viewModel.accessPoints.isEmpty {
                Placeholder(text: "Scanning", message: "Scanning for Wi-Fi", systemImage: "wifi")
            } else {
                List {
                    Section("Access Points") {
                        ForEach(viewModel.accessPoints) { accessPoint in
                            APWiFiScanView(wiFiScan: accessPoint, selected: viewModel.wifiNetwork == accessPoint.wifi)
                                .onTapGesture {
                                    viewModel.wifiNetwork = accessPoint.wifi
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
            viewModel.startScanning()
        }
        .toolbar {
            Button("Close") {
                viewModel.stopScanning()
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
