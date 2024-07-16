//
//  DeviceView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE
import iOS_Common_Libraries

// MARK: - DeviceView

struct DeviceView: View {
    
    // MARK: Properties
    
    @StateObject var viewModel: ViewModel
    @State var unprovisionSheet: Bool = false
    
    // MARK: View
    
    var body: some View {
        VStack {
            switch viewModel.peripheralConnectionStatus {
            case .connecting, .connected, .paired:
                deviceInfo
                    .confirmationDialog("Unprovision", isPresented: $unprovisionSheet) {
                        Button("Unprovision", role: .destructive) {
                            try? viewModel.unprovision()
                        }
                        Button("Cancel", role: .cancel) {
                            // No-op.
                        }
                    } message: {
                        Text("Are you sure that you want to unset the configuration?")
                    }
            case .disconnected(let reason):
                switch reason {
                case .byRequest:
                    Placeholder(text: "Disconnected", image: "bluetooth_disabled")
                case .error(let error):
                    Placeholder(text: "The device was disconnected unexpectedly: \(error.localizedDescription)", image: "bluetooth_disabled", action: {
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
        .onAppear {
            viewModel.connect()
        }
        .onDisappear {
            viewModel.disconnect()
        }
        .alert(viewModel.error?.title ?? "Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.error = nil
                viewModel.showError = false
            }
        } message: {
            if let message = viewModel.error?.message {
                Text(message)
            }
        }
    }
    
    @ViewBuilder
    var deviceInfo: some View {
        VStack {
            List {
                DeviceStatusSection()
                
                ScannerSection()
                
                AccessPointSection(accessPoint: viewModel.wifiNetwork?.accessPoint(), password: $viewModel.password, showVolatileMemory: viewModel.showVolatileMemory, volatileMemory: $viewModel.volatileMemory, footer: viewModel.infoFooter)
            }
            .environmentObject(viewModel)
            .listStyle(.insetGrouped)
            
            Spacer()
            
            HStack {
                Button {
                    unprovisionSheet = true
                } label: {
                    Text("Forget")
                        .frame(maxWidth: .infinity)
                }
                .tint(.nordicRed)
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 4)
                .isHidden(!viewModel.buttonConfiguration.showUnsetButton, remove: true)
                .disabled(!viewModel.buttonConfiguration.enabledUnsetButton)
                
                Button {
                    Task {
                        do {
                            try viewModel.startProvision()
                        }
                    }
                } label: {
                    Text(viewModel.buttonConfiguration.provisionButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 4)
                .disabled(!viewModel.buttonConfiguration.enabledProvisionButton)
                .accessibilityIdentifier("prov_button")
            }
            .padding(.horizontal)
        }
        .background(Color.formBackground)
    }
}

// MARK: - Preview

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
        .previewDisplayName("iPhone 14 Pro")
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
#endif
