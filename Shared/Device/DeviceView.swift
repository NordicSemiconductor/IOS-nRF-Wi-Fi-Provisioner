//
//  DeviceView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import SwiftUI
import NordicStyle
import Provisioner2

struct DeviceView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            switch viewModel.peripheralConnectionStatus {
            case .connecting:
                Placeholder(
                    text: "Connecting",
                    image: "bluetooth"
                )
            case .connected:
                deviceInfo
            case .disconnected(let reason):
                switch reason {
                case .byRequest:
                    Placeholder(text: "Disconnected", image: "bluetooth_disabled")
                case .error(let e):
                    // TODO: Change Error type
                    Placeholder(text: e.localizedDescription, image: "bluetooth_disabled", action: {
                        Button("Reconnect") {
                            Task {
                                self.viewModel.connect()
                            }
                        }
                        .buttonStyle(NordicButtonStyle())
                    })
                    .padding()
                }
            }
        }
        .onFirstAppear {
            viewModel.connect()
        }
    }
    
    @ViewBuilder
    var deviceInfo: some View {
        VStack {
            Form {
                DeviceSection(provisioned: viewModel.provisioned)
                DeviceStatusSection(
                    version: viewModel.version,
                    connectionStatus: viewModel.wifiState,
                    forceShowProvisionInProgress: viewModel.forceShowProvisionInProgress,
                    provisioningError: viewModel.provisioningError,
                    ip: viewModel.deviceStatus?.connectionInfo?.ip?.description
                )
                AccessPointSection(
                    viewModel: viewModel,
                    inProgress: viewModel.inProgress,
                    wifiInfo: viewModel.displayedWiFi,
                    passwordRequired: viewModel.passwordRequired,
                    showFooter: viewModel.showFooter,
                    showVolatileMemory: false,
                    password: $viewModel.password,
                    volatileMemory: $viewModel.volatileMemory,
                    showAccessPointList: $viewModel.showAccessPointList
                )
            }
            
            Spacer()
            Button(viewModel.buttonState.title) {
                Task {
                    do {
                        try await viewModel.startProvision()
                    }
                }
            }
            .disabled(!viewModel.buttonState.isEnabled || viewModel.displayedWiFi == nil)
            .buttonStyle(viewModel.buttonState.style)
            .padding()
        }
    }
}

#if DEBUG

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceView(
                viewModel: MockDeviceViewModel(deviceId: "")
            )
            .navigationTitle("Device Name")
        }
        .setupNavBarBackground()
        .tint(.nordicBlue)
        .previewDisplayName("iPhone 14 Pro")
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
#endif
