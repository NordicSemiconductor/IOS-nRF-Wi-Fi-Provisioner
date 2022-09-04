//
//  AccessPointList.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 26/07/2022.
//

import SwiftUI
import NordicStyle

struct AccessPointList: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: AccessPointListViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.accessPoints) { ap in
                Picker(selection: $viewModel.selectedAccessPoint, content: {
                    ForEach(viewModel.allChannels(for: ap)) { accessPoint in
                        HStack {
                            Label {
                                Text("\(accessPoint.channel)")
                            } icon: {
                                RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: ap.rssi))
                                        .frame(maxWidth: 30, maxHeight: 20)
                            }
                        }
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

                /*
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                    viewModel.selectedAccessPoint = ap
                } label: {
                    HStack {
                        Label(ap.ssid, systemImage: ap.isOpen ? "lock.open" : "lock")
                                .tint(Color.accentColor)
                        Spacer()
                        RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: ap.rssi))
                                .frame(maxWidth: 30, maxHeight: 20)
                    }
                }
                 */
            }
        }
        .navigationTitle("Wi-Fi")
                .onAppear {
                    Task {
//                        await viewModel.startScan()
                    }
                }
                .onDisappear {
                    Task {
//                        try? await viewModel.stopScan()
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
        AccessPointList(viewModel: AccessPointListViewModel(provisioner: MockProvisioner()))
    }
}
