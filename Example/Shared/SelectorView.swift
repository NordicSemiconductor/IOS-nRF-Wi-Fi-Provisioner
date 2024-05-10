//
//  SelectorView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI

// MARK: - Selector View

struct SelectorView: View {
    
    // MARK: Properties
    
    @EnvironmentObject var vmFactory: DeviceViewModelFactory
    
    // MARK: View
    
    var body: some View {
        List {
            Section("Provisioning Modes") {
                NavigationLink {
                    ScannerView(viewModel: ScannerViewModel())
                        .environmentObject(vmFactory)
                } label: {
                    Label("Provision over BLE", image: "bluetooth")
                }
                
                Text("""
                This mode uses secure Bluetooth LE link to transfer Wi-Fi credentials to the provisionee and verify provisioning status.
                """)
                .font(.caption)
            }
            
            Section {
                NavigationLink {
                    ProvisionOverWiFiView()
                } label: {
                    Label("Provision over Wi-Fi", systemImage: "wifi")
                }
                
                Text("""
                This mode uses a temporary Wi-Fi network (Soft AP) created by the provisionee to send Wi-Fi credentials. Communication is encrypted using TLS.
                """)
                .font(.caption)
            }
            
            Section {
                NavigationLink {
                    ProvisionOverNFCView()
                } label: {
                    Label("Provision over NFC", systemImage: "tag.fill")
                }
                
                Text("""
                This mode sends SSID and network credentials over NFC (Near Field Communication). It does not give any feedback on whether the device successfully connected to the desired network.
                """)
                .font(.caption)
            }
            
            Section("About") {
                Text("""
                nRF Wi-Fi Provisioner is designed to work with nRF700x DKs, or nRF700x-powered devices that are running firmware capable of being provisioned. This app, via provisioning process, configures nRF700x with the necessary credentials to access the internet though the wireless network interface of your choice.
                """)
                .font(.footnote)
            }
            .listRowBackground(Color.clear)
        }
    }
}
