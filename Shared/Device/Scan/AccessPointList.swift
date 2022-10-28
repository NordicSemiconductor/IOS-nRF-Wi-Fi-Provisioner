//
//  AccessPointList.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 26/07/2022.
//

import SwiftUI
import NordicStyle
import Provisioner

struct AccessPointList: View {
    @StateObject var viewModel: AccessPointListViewModel
    
    var body: some View {
        VStack {
            if viewModel.accessPoints.isEmpty {
                Placeholder(text: "Scanning", message: "Scanning for Wi-Fi", systemImage: "wifi")
            } else {
                list()
            }
        }
        .navigationTitle("Wi-Fi")
        .onAppear {
            Task {
                await viewModel.startScan()
            }
        }
        .onDisappear {
            Task {
                try await viewModel.stopScan()
            }
        }
        .toolbar {
            ProgressView()
                .isHidden(!viewModel.isScanning, remove: true)
        }
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
                Text("Access Points")
            }
        }
    }
    //*
    @ViewBuilder
    private func channelPickerList(accessPoint: AccessPoint) -> some View {
        NavigationLink {
            ChannelPicker(
                channels: viewModel.allChannels(for: accessPoint),
                selectedChannel: $viewModel.selectedAccessPointId
            ).navigationTitle(accessPoint.ssid)
        } label: {
            HStack {
                Label(accessPoint.ssid, systemImage: accessPoint.isOpen ? "lock.open" : "lock")
                    .tint(Color.accentColor)
                Spacer()
                RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: accessPoint.rssi))
                    .frame(maxWidth: 30, maxHeight: 20)
            }
        }
        .accessibility(identifier: "access_point_\(viewModel.accessPoints.firstIndex(of: accessPoint) ?? -1)")
    }
    // */
    
    //*
    @ViewBuilder
    private func channelPicker(accessPoint: AccessPoint) -> some View {
        Picker(selection: $viewModel.selectedAccessPoint, content: {
            Section {
                ForEach(viewModel.allChannels(for: accessPoint), id: \.id) { channel in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Channel \(channel.channel)")
                            Text(channel.bssid)
                                .font(.caption)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: channel.rssi))
                                .frame(maxWidth: 30, maxHeight: 20)
                            Text(channel.frequency.stringValue.description)
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
                Label(accessPoint.ssid, systemImage: accessPoint.isOpen ? "lock.open" : "lock")
                    .tint(Color.accentColor)
                Spacer()
                RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: accessPoint.rssi))
                    .frame(maxWidth: 30, maxHeight: 20)
            }
        })
        .navigationBarTitle("Select Access Point")
        .accessibility(identifier: "access_point_\(viewModel.accessPoints.firstIndex(of: accessPoint) ?? -1)")
    }
     // */
}

#if DEBUG
struct AccessPointList_Previews: PreviewProvider {
    class DummyAccessPointListViewModel: AccessPointListViewModel {
        override var isScanning: Bool {
            get {
                true
            } set {
                
            }
        }
        
        override var accessPoints: [WifiInfo] {
            get {
                [
                    AccessPoint(
                        ssid: "Test",
                        bssid: "bssid",
                        id: "id",
                        isOpen: true,
                        channel: 1,
                        rssi: -50, frequency: ._5GHz
                    )
                ]
            } set {
                
            }
        }
        
        override func startScan() async {
            
        }
        
        override func stopScan() async throws {
            
        }
        
        override func allChannels(for accessPoint: WifiInfo) -> [WifiInfo] {
            [
                AccessPoint(
                    ssid: "Test",
                    bssid: "bssid",
                    id: "id",
                    isOpen: true,
                    channel: 1,
                    rssi: -50,
                    frequency: ._5GHz
                )
            ]
        }
    }
    
    static var previews: some View {
        NavigationView {
            AccessPointList(
                viewModel: DummyAccessPointListViewModel(
                    provisioner: MockProvisioner(),
                    accessPointSelection: MockDeviceViewModel(fakeStatus: .connected)
                )
            )
        }
    }
}
#endif
