//
//  DeviceView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import SwiftUI
import NordicStyle
import Provisioner

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
                Placeholder(text: e.message, image: "bluetooth_disabled", action: {
                    Button("Reconnect") {
                        Task {
                            try await self.viewModel.connect()
                        }
                    }
                            .buttonStyle(NordicButtonStyle())
                })
                        .padding()
            case .connected:
                deviceInfo
            case .disconnected:
                Placeholder(text: "Disconnected", image: "bluetooth_disabled")
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
    }
    
    @ViewBuilder
    var deviceInfo: some View {
        VStack {
            Form {
                // MARK: Device Name
                Section("Device") {
                    HStack {
                        NordicLabel("Device Name", image: "bluetooth")
                            
                        Spacer()
                        Text(viewModel.deviceName).foregroundColor(.secondary)
                    }
                }

                // MARK: Device Info
                Section("Device Status") {
                    HStack {
                        NordicLabel("Version", systemImage: "wrench.and.screwdriver")
                        Spacer()
                        Text(viewModel.version).foregroundColor(.secondary)
                    }
                    
                    HStack {
                        NordicLabel("Wi-Fi Status", systemImage: "wifi")
                            .tint(.nordicBlue)
                        Spacer()
                        ReversedLabel {
                            Text(viewModel.wifiState?.description ?? "Unprovisioned")
                        } image: {
                            StatusIndicatorView(status: viewModel.wifiState, forceProgress: viewModel.forceShowProvisionInProgress)
                        }
                        .status(viewModel.wifiState ?? .disconnected)
                    }
                }

                // MARK: Access Points
                Section("Access Point") {
                    NavigationLink {
                        AccessPointList(viewModel: viewModel)
                    } label: {
                        HStack {
                            NordicLabel("Access Point", systemImage: "wifi.circle")
                            Spacer()
                            Text(viewModel.selectedAccessPoint?.ssid ?? "Not Selected")
                                    .foregroundColor(.secondary)
                        }
                        .disabled(viewModel.wifiState?.isInProgress ?? false)
                    }
                    .disabled(viewModel.wifiState?.isInProgress ?? false)

                    if viewModel.passwordRequired {
                        SecureField("Password", text: $viewModel.password)
                    }
                }
            }
            if viewModel.selectedAccessPoint != nil {
                Spacer()
                Button(viewModel.buttonState.title) {
                    Task {
                        do {
                            try await viewModel.startProvision()
                        }
                    }
                }
                .disabled(!viewModel.buttonState.isEnabled)
                .buttonStyle(viewModel.buttonState.style)
                .padding()
            }
        }
    }
}

struct StatusIndicatorView: View {
    let status: Provisioner.WiFiStatus?
    var forceProgress: Bool = false
    
    var body: some View {
        switch (status, forceProgress) {
        case (_, true):
            ProgressView()
        case (.connected?, _):
            Image(systemName: "checkmark")
        case (.association?, false): ProgressView()
        case (.authentication?, false):  ProgressView()
        case (.obtainingIp?, false):  ProgressView()
        case (.connectionFailed(_)?, _):
            Image(systemName: "info.circle")
        default: Text("")
        }
    }
}

#if DEBUG
struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceView(viewModel: MockDeviceViewModel(index: 1))
        }
        .setupNavBarBackground()
    }
    
    
}
#endif
