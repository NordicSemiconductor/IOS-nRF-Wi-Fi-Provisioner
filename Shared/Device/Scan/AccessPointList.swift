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
    @ObservedObject var viewModel: DeviceViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.accessPoints) { ap in
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
                        do {
                            try await viewModel.stopScan()
                        }
                    }
                }
    }
}

struct AccessPointList_Previews: PreviewProvider {
    static var previews: some View {
        AccessPointList(viewModel: DeviceViewModel(peripheralId: UUID()))
    }
}
