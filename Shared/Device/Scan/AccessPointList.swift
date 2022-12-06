//
//  AccessPointList.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 26/07/2022.
//

import SwiftUI
import NordicStyle
import NordicWiFiProvisioner

struct AccessPointList: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ViewModel()
    
    let provisioner: DeviceManager
    let wifiSelection: AccessPointSelection
    
    init(provisioner: DeviceManager, wifiSelection: AccessPointSelection) {
        self.provisioner = provisioner
        self.wifiSelection = wifiSelection
    }
    
    var body: some View {
        VStack {
            if viewModel.accessPoints.isEmpty {
                Placeholder(text: "Scanning", message: "Scanning for Wi-Fi", systemImage: "wifi")
            } else {
                list()
            }
        }
        .navigationTitle("Wi-Fi")
        .onFirstAppear {
            viewModel.setupAndScan(provisioner: provisioner, scanDelegate: viewModel, wifiSelection: wifiSelection)
        }
        .toolbar {
            Button("Close", action: close)
        }
        .alert(viewModel.error?.title ?? "Error", isPresented: $viewModel.showError) {
            Button("Cancel", role: .cancel) {}
        } message: {
            if let message = viewModel.error?.message {
                Text(message)
            }
        }
    }
    
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
    
    @ViewBuilder
    private func list() -> some View {
        List {
            Section {
                ForEach(viewModel.accessPoints) {
                    if #available(iOS 16, *) {
                        channelPickerList(accessPoint: $0)
                    } else {
                        channelPicker(accessPoint: $0)
                    }
                }
            } header: {
                HStack {
                    Text("Access Points")
                    Spacer()
                    ProgressView()
                        .isHidden(viewModel.isScanning, remove: true)
                }
            }
        }
    }
    //*
    @ViewBuilder
    private func channelPickerList(accessPoint: ViewModel.ScanResult) -> some View {
        NavigationLink {
            ChannelPicker(
                channels: viewModel.allChannels(for: accessPoint.wifi),
                selectedChannel: $viewModel.selectedAccessPointId
            ).navigationTitle(accessPoint.wifi.ssid)
        } label: {
            HStack {
                Label {
                    Text(accessPoint.wifi.ssid)
                } icon: {
                    Image(systemName: accessPoint.wifi.isOpen ? "lock.open" : "lock")
                        .renderingMode(.template)
                }
                Spacer()
                accessPoint.rssi.map {
                    RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: $0))
                        .frame(maxWidth: 30, maxHeight: 20)
                }
            }
        }
        .accessibility(identifier: "access_point_\(viewModel.accessPoints.firstIndex(of: accessPoint) ?? -1)")
    }
    
    @ViewBuilder
    private func channelPicker(accessPoint: ViewModel.ScanResult) -> some View {
        Picker(selection: $viewModel.selectedAccessPoint, content: {
            Section {
                ForEach(viewModel.allChannels(for: accessPoint.wifi), id: \.id) { channel in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Channel \(channel.wifi.channel)")
                            Text(channel.wifi.bssid.description)
                                .font(.caption)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            channel.rssi.map {
                                RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: $0))
                                    .frame(maxWidth: 30, maxHeight: 20)
                            }
                            Text(channel.wifi.band?.description ?? "- GHz")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tag(Optional(channel))
                }
            } header: {
                Text("Select Channel")
            }
        }, label: {
            HStack {
                Label(accessPoint.wifi.ssid, systemImage: accessPoint.wifi.isOpen ? "lock.open" : "lock")
                    .tint(Color.accentColor)
                Spacer()
                accessPoint.rssi.map {
                    RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: $0))
                        .frame(maxWidth: 30, maxHeight: 20)
                }
            }
        })
        .navigationBarTitle("Select Access Point")
        .accessibility(identifier: "access_point_\(viewModel.accessPoints.firstIndex(of: accessPoint) ?? -1)")
    }
}

#if DEBUG

struct AccessPointList_Previews: PreviewProvider {
    struct Selection: AccessPointSelection {
        var selectedWiFi: NordicWiFiProvisioner.WifiInfo?
        
        var showAccessPointList: Bool = false
    }
    
    class MockScanProvisioner: DeviceManager {
        typealias SR = AccessPointList.ViewModel.ScanResult
        override func startScan(scanParams: ScanParams) throws {
            let scanResults = [
                SR(wifi: .wifi1, rssi: -40),
                SR(wifi: .wifi2, rssi: -60),
                SR(wifi: .wifi3, rssi: -80),
                SR(wifi: .wifi4, rssi: -100),
            ]
            
            for sr in scanResults {
                self.provisionerScanDelegate?.deviceManager(DeviceManager(deviceId: ""), discoveredAccessPoint: sr.wifi, rssi: sr.rssi)
            }
        }
    }
    
    class DummyAccessPointListViewModel: AccessPointList.ViewModel {
        override func setupAndScan(provisioner: DeviceManager, scanDelegate: WiFiScanerDelegate, wifiSelection: AccessPointSelection) {
            self.provisioner = MockScanProvisioner(deviceId: "")
            self.provisioner.provisionerScanDelegate = self
            try? self.provisioner.startScan(scanParams: ScanParams())
        }
    }
    
    static var previews: some View {
        NavigationView {
            AccessPointList(
                provisioner: MockScanProvisioner(deviceId: ""),
                wifiSelection: Selection()
            )
        }
        .tint(.orange)
    }
}
#endif
