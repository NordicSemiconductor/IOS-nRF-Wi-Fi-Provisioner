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
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewModel: AccessPointListViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.accessPoints) { ap in
                Picker(selection: $viewModel.selectedAccessPoint, content: {
                    ForEach(viewModel.allChannels(for: ap)) { accessPoint in
                        Label {
                            Text("Channel: \(accessPoint.channel)")
                        } icon: {
                            RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: accessPoint.rssi))
                                .frame(maxWidth: 30, maxHeight: 20)
                        }
                        .tag(Optional(accessPoint))
                    }
                    .navigationBarTitle("Select Channel")
                }, label: {
                    HStack {
                        Label(ap.ssid, systemImage: ap.isOpen ? "lock.open" : "lock")
                            .tint(Color.accentColor)
                        Spacer()
                        RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: ap.rssi))
                            .frame(maxWidth: 30, maxHeight: 20)
                    }
                })
                .navigationBarTitle("Select Access Point")
            }
        }
        .navigationTitle("Wi-Fi")
                .onAppear {
                    Task {
                        await viewModel.startScan()
                    }
                }
                .toolbar {
                    ProgressView()
                        .isHidden(!viewModel.isScanning, remove: true)
                }
    }
}

struct AccessPointList_Previews: PreviewProvider {
    static var previews: some View {
        AccessPointList()
            .environmentObject(AccessPointListViewModel(provisioner: MockProvisioner()))
    }
}
