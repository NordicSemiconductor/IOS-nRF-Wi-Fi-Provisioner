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

                

                /*
                    .sheet(isPresented: $unprovisionSheet) {
                        ActionSheet(
                            title: Text("Unprovision the Device?"),
                            message: Text("Are you sure that you want to unset the configuration?"),
                            buttons: [
                                .destructive(Text("Unprovision")),
                                .cancel()
                            ]
                        )
                    }
                 */
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
                        .buttonStyle(NordicButtonStyle())
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
                AccessPointList(provisioner: viewModel.provisioner, wifiSelection: viewModel)
            }
            .onDisappear {
                try? viewModel.provisioner.stopScan()
            }
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
                    connectionError: viewModel.provisioningError,
                    ip: viewModel.deviceStatus?.connectionInfo?.ip?.description,
                    provisioned: viewModel.provisioned
                )
                AccessPointSection(
                    viewModel: viewModel,
                    inProgress: viewModel.inProgress,
                    wifiInfo: viewModel.displayedWiFi,
                    passwordRequired: viewModel.passwordRequired,
                    showFooter: viewModel.showFooter,
                    showVolatileMemory: viewModel.showVolatileMemory,
                    password: $viewModel.password,
                    volatileMemory: $viewModel.volatileMemory,
                    showAccessPointList: $viewModel.showAccessPointList
                )
            }
            
            Spacer()
            
            VStack {
                Button("Unprovision") {
                    unprovisionSheet = true
                }
                .buttonStyle(HollowDistructiveButtonStyle())
                .isHidden(!viewModel.provisioned, remove: true)
                .disabled(viewModel.provisioningInProgress)
                
                Button(viewModel.buttonState.title) {
                    Task {
                        do {
                            try viewModel.startProvision()
                        }
                    }
                }
                .disabled(!viewModel.buttonState.isEnabled || viewModel.displayedWiFi == nil)
                .buttonStyle(viewModel.buttonState.style)
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
    
    override var showVolatileMemory: Bool {
        get { true }
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
    
    override var provisioningInProgress: Bool {
        get { true }
        set { }
    }
    
    override var deviceStatus: DeviceStatus? {
        get { DeviceStatus(
            state: .connected,
            provisioningInfo: WifiInfo(ssid: "Home", bssid: .mac1, channel: 3),
            connectionInfo: ConnectionInfo(ip: IPAddress(data: 0xff_ff_ff_ff_ff_FF.toData().suffix(5))),
            scanInfo: nil
        ) }
        set { }
    }
    
    override var displayedWiFi: WifiInfo? {
        get {
            WifiInfo(
                ssid: "Nordic Guest",
                bssid: MACAddress(i: 0xff_02_04_04_33_fa),
                band: .band5Gh,
                channel: 2,
                auth: .wpa2Psk
            )
        }
        set {
            
        }
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
        .setupNavBarBackground()
        .tint(.nordicBlue)
        .previewDisplayName("iPhone 14 Pro")
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
#endif
