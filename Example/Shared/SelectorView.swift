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
                    Label("Provision Over BLE", image: "bluetooth")
                }
                
                Text("""
                This Mode Allows for Constant Communication With the Provisioning Device Since It Keeps Our Wi-Fi Usage Exclusive to the Provisioning Process.
                """)
                .font(.caption)
            }
            
            Section {
                NavigationLink {
                    ProvisionOverWiFiView()
                } label: {
                    Label("Provision Over Wi-Fi", systemImage: "wifi")
                }
                
                Text("""
                This Mode Requires Your iPhone To Switch to the Same Wi-Fi Network As the Device We Want to Provision, Communicate With It, and Then Wait for It To Connect to the Network We’d Like to Provision It To.
                """)
                .font(.caption)
            }
            
            #if DEBUG
            Section {
                NavigationLink {
                    ProvisionOverNFCView()
                } label: {
                    Label("Provision Over NFC", systemImage: "tag.fill")
                }
                
                Text("""
                """)
                .font(.caption)
            }
            #endif
            
            Section("About") {
                Text("""
                nRF Wi-Fi Provisioner Is Designed To Work With nRF700x DKs, or nRF700x-Powered Devices That Are Running Firmware Capable of Being Provisioned. This App, via a Provisioning Process, Configures nRF700x With the Necessary Credentials To Access the Internet Though the Wireless Network Interface of Your Choice.
                """)
                .font(.footnote)
            }
            .listRowBackground(Color.clear)
        }
    }
}
