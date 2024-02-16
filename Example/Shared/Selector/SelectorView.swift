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
                    .font(.title3)
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
                
                Text("""
                What is nRF Wi-Fi Provisioner For?
                
                nRF Wi-Fi Provisioner is designed to work with nRF700x DKs, or nRF700x-powered devices that are running firmware capable of being provisioned via these two methods, Bluetooth or Wi-Fi. Both have advantages & disadvantages, but the end result should be that your device can use its nRF7000x-derived capabilities to connect directly to the Internet. This App, via a provisioning process, configures nRF700x with the necessary credentials to access the Internet though the wireless network interface of your choice.
                """)
                .font(.footnote)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
    }
}
