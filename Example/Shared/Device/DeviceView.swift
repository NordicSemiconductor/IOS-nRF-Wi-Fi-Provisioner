//
//  DeviceView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE

struct DeviceView: View {
    @StateObject var viewModel: ViewModel
    @State var unprovisionSheet: Bool = false
    
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
                    .confirmationDialog("Unprovision", isPresented: $unprovisionSheet) {
                        Button("Unset", role: .destructive) {
                            try? viewModel.unprovision()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure that you want to unset the configuration?")
                    }
                    .alert(viewModel.error?.title ?? "Error", isPresented: $viewModel.showError) {
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        if let message = viewModel.error?.message {
                            Text(message)
                        }
                    }
            case .disconnected(let reason):
                switch reason {
                case .byRequest:
                    Placeholder(text: "Disconnected", image: "bluetooth_disabled")
                case .error(_):
                    Placeholder(text: "The device was disconnected unexpectedly.", image: "bluetooth_disabled", action: {
                        Button("Reconnect") {
                            Task {
                                self.viewModel.connect()
                            }
                        }
                    })
                    .padding()
                }
            }
        }
        .onFirstAppear {
            viewModel.connect()
        }
        .sheet(isPresented: $viewModel.showAccessPointList) {
            NavigationView {
                AccessPointList(provisioner: viewModel.provisioner)
            }
            .navigationViewStyle(.stack)
            .onDisappear {
                try? viewModel.provisioner.stopScan()
            }
        }
    }
    
    @ViewBuilder
    var deviceInfo: some View {
        VStack {
            Form {
                DeviceSection(
                    provisioned: viewModel.provisioned,
                    provisionState: viewModel.provisionedState
                )
                
                DeviceStatusSection(
                    version: viewModel.version,
                    connectionStatus: viewModel.connectionStatus.status,
                    statusProgress: viewModel.connectionStatus.statusProgressState,
                    showConnectionStatus: viewModel.connectionStatus.showStatus,
                    connectionError: nil,
                    ip: viewModel.connectionStatus.ipAddress,
                    showIp: viewModel.connectionStatus.showIpAddress
                )
                
                AccessPointSection(
                    viewModel: viewModel,
                    wifi: viewModel.wifiNetwork,
                    showPassword: viewModel.showPassword,
                    footer: viewModel.infoFooter,
                    showVolatileMemory: viewModel.showVolatileMemory,
                    password: $viewModel.password,
                    volatileMemory: $viewModel.volatileMemory,
                    showAccessPointList: $viewModel.showAccessPointList
                )
            }
            
            Spacer()
            
            VStack {
                Button("Forget Configuration") {
                    unprovisionSheet = true
                }
                .foregroundStyle(Color.nordicRed)
                .isHidden(!viewModel.buttonConfiguration.showUnsetButton, remove: true)
                .disabled(!viewModel.buttonConfiguration.enabledUnsetButton)
                
                Button(viewModel.buttonConfiguration.provisionButtonTitle) {
                    Task {
                        do {
                            try viewModel.startProvision()
                        }
                    }
                }
                .disabled(!viewModel.buttonConfiguration.enabledProvisionButton)
                .accessibilityIdentifier("prov_button")
            }
            .padding()
        }
    }
}

#if DEBUG

class MockDeviceViewModel: DeviceView.ViewModel {
    override var version: String {
        get { "14" }
        set { }
    }
    
    override var peripheralConnectionStatus: PeripheralConnectionStatus {
        get { .connected }
        set { }
    }
    
    override var provisioned: Bool {
        get { true }
        set { }
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceView(
                viewModel: MockDeviceViewModel(deviceId: "")
            )
            .navigationTitle("Device Name")
        }
//        .setupNavBarBackground()
//        .tint(.nordicBlue)
        .previewDisplayName("iPhone 14 Pro")
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
#endif
