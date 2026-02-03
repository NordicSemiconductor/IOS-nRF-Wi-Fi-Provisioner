//
//  SelectorView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - Selector View

struct SelectorView: View {
    
    // MARK: Properties
    
    @EnvironmentObject private var viewModel: AppViewModel
    @EnvironmentObject private var vmFactory: DeviceViewModelFactory
    
    // MARK: view
    
    var body: some View {
        List {
            Section {
                NavigationLink {
                    ScannerView(viewModel: ScannerViewModel())
                        .environmentObject(vmFactory)
                } label: {
                    Label("Provision over Bluetooth LE", image: "bluetooth")
                }
                .accessibilityIdentifier("selector_ble_provisioning_btn")
            } header: {
                Text("Provisioning Modes")
            } footer: {
                Text("""
                This mode uses secure Bluetooth Low Energy link to transfer Wi-Fi credentials to the provisionee and verify provisioning status.
                """)
            }
            
            Section {
                NavigationLink {
                    ProvisioningSetupView()
                } label: {
                    Label("Provision over Wi-Fi", systemImage: "wifi")
                }
                .accessibilityIdentifier("selector_wifi_provisioning_btn")
            } footer: {
                Text("""
                This mode uses a temporary Wi-Fi network (SoftAP) created by the provisionee to send Wi-Fi credentials. Communication is encrypted using TLS.
                """)
            }
            
            Section {
                NavigationLink {
                    ProvisionOverNFCView()
                } label: {
                    Label("Provision over NFC", systemImage: "tag.fill")
                }
                .accessibilityIdentifier("selector_nfc_provisioning_btn")
            } footer: {
                Text("""
                This mode sends SSID and network credentials over NFC (Near Field Communication). It does not give any feedback on whether the device successfully connected to the desired network.
                """)
            }
            
            Section {
                Button {
                    viewModel.showStartInfo = true
                } label: {
                    Label("About nRF Wi-Fi Provisioner", systemImage: "app.gift")
                }
                
                Link(destination: URL(string: "https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner")!) {
                    Label("Source Code", systemImage: "keyboard")
                }
                
                Link(destination: URL(string: "https://devzone.nordicsemi.com/")!) {
                    Label("Help (Nordic DevZone)", systemImage: "lifepreserver")
                }
            } header: {
                Text("Links")
            } footer: {
                Text(Constant.copyright)
                    .foregroundStyle(Color.nordicMiddleGrey)
            }
            .setAccent(.universalAccentColor)
            .tint(.primarylabel)
        }
    }
}
