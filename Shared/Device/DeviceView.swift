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
            switch viewModel.state {
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
        .alert(viewModel.errorTitle ?? "", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {
                
            }
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
                        Text(viewModel.deviceName)
                    }
                }
                
                Section("Device Status") {
                    HStack {
                        Label("Version", systemImage: "wrench.and.screwdriver")
                        Spacer()
                        Text(viewModel.versien)
                    }
                    
                    HStack {
                        Label("Wi-Fi Status", systemImage: "wifi")
                            .tint(.nordicBlue)
                        Spacer()
                        Text(viewModel.state.description)
                    }
                }
                
                Section("Access Point") {
                    NavigationLink(isActive: $viewModel.activeScan) {
                        AccessPointList(viewModel: viewModel)
                    } label: {
                        HStack {
                            Label("Access Point", systemImage: "wifi.circle")
                            Spacer()
                            Text(viewModel.selectedAccessPoint?.name ?? "Not Selected")
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
                    
                }
                .disabled(viewModel.password.count < 6)
                .buttonStyle(NordicButtonStyle())
                .padding()
            }
        }
        
    }
}

#if DEBUG
struct DeviceView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            DeviceView(viewModel: MockDeviceViewModel(index: 2))
        }
    }
}
#endif
