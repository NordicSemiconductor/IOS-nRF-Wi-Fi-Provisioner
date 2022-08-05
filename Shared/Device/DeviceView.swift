//
//  DeviceView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import SwiftUI
import NordicStyle

struct DeviceView: View {
    @ObservedObject var viewModel: DeviceViewModel
    
    var body: some View {
        VStack {
            switch viewModel.connectionStatus {
            case .connecting:
                Placeholder(
                    text: "Connecting",
                    image: "bluetooth"
                )
            case .failed(let e):
                Placeholder(text: e.message, image: "bluetooth_disabled")
            case .connected:
                deviceInfo
            }
        }
        .navigationTitle("Device Info")
        .onAppear {
            Task {
                do {
                    try await viewModel.connect()
                    try await viewModel.readInformation()
                }
            }
        }
        .alert(viewModel.connectionError?.title ?? "", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    @ViewBuilder
    var deviceInfo: some View {
        VStack {
            Form {
                Section() {
                    HStack {
                        Label("Device Name", image: "bluetooth")
                            .tint(.nordicBlue)
                        Spacer()
                        Text(viewModel.deviceName).foregroundColor(.secondary)
                    }
                }
                
                Section("Device Status") {
                    HStack {
                        Label("Version", systemImage: "wrench.and.screwdriver")
                        Spacer()
                        Text(viewModel.version).foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Wi-Fi Status", systemImage: "wifi")
                            .tint(.nordicBlue)
                        Spacer()
                        ReversedLabel {
                            Text(viewModel.wifiState?.description ?? "Unprovisioned")
                        } image: {
                            StatusIndicatorView(status: viewModel.wifiState)
                        }
                        .status(viewModel.wifiState ?? .disconnected)

                    }
                }
                
                Section("Access Point") {
                    NavigationLink {
                        AccessPointList(viewModel: viewModel)
                    } label: {
                        HStack {
                            Label("Access Point", systemImage: "wifi.circle")
                            Spacer()
                            Text(viewModel.selectedAccessPoint?.ssid ?? "Not Selected")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if viewModel.passwordRequired {
                        SecureField("Password", text: $viewModel.password)
                    }
                }
                
                
            }
            if viewModel.selectedAccessPoint != nil {
                Spacer()
                Button("START_PROVISIONING_BTN") {
                    Task {
                        do {
                            try await viewModel.startProvision()
                        }
                    }
                }
                .disabled(viewModel.password.count < 6 && viewModel.selectedAccessPoint?.isOpen == false)
                .buttonStyle(NordicButtonStyle())
                .padding()
            }
        }
        
    }
}

struct StatusIndicatorView: View {
    let status: DeviceViewModel.WiFiStatus?
    
    var body: some View {
        switch status {
        case .connected?:
            Image(systemName: "checkmark")
        case .failed(_)?:
            Image(systemName: "info.circle")
        case .association?, .authentication?, .connecting?, .obtainingIp?:
            ProgressView()
        default:
            Image("")
        }
    }
}

#if DEBUG
struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceView(viewModel: MockDeviceViewModel(index: 1))
        }
    }
    
    
}
#endif
