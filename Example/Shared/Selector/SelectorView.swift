//
//  SelectorView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI

struct SelectorView: View {
    
    var body: some View {
        List {
            Section {
                Text("Select Mode")
                    .font(.subheadline)
                    .listRowBackground(Color.clear)
                
                NavigationLink {
                    ScannerView(viewModel: ScannerViewModel())
                } label: {
                    Label("Provision over BLE", image: "bluetooth")
                }
                
                NavigationLink {
                    ProvisionOverWiFiView()
                } label: {
                    Label("Provision over Wi-Fi", systemImage: "wifi")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
