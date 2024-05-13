//
//  IntroView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI

// MARK: - IntroView

struct IntroView: View {
    
    // MARK: Properties
    
    @State private var animationAmount = 1.0
    @State private var selection: Int? = nil
    
    @StateObject var viewModel = IntroViewModel()
    
    @Binding var show: Bool
    @Binding var dontShowAgain: Bool
    
    // MARK: View
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Image(viewModel.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .listRowSeparator(.hidden)
                    
                    Text("Version: \(viewModel.version)")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Features:")
                            .bold()
                            .font(.title2)
                        
                        Text("• Provision of a device over BLE (Bluetooth Low Energy), Wi-Fi (Access Point) or NFC (Near-Field Communication)")
                        Text("• (Optionally) verify correct provisioning of the device.")
                        Text("• Re-provision already provisioned devices to an alternate network.")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Requirements:")
                            .bold()
                            .font(.title2)
                        
                        Text("• [nRF700x DK](https://nordicsemi.no)")
                        Text("• Corresponding provisioning application running on device (each provisioning method requires a specific firmware)")
                    }
                    
                    Text("Make sure the device is powered ON, in range and correct firmware is flashed.")
                }
                .listRowSeparator(.hidden)
                
                HStack {
                    Toggle("Don't show again", isOn: $dontShowAgain)
                }
                
                Button("START_PROVISIONING_BTN") {
                    show = false
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .listRowSeparator(.hidden)
                .accessibilityIdentifier("start_provisioning_btn")
            }
            .navigationTitle("Welcome")
            .onAppear { try? viewModel.readInfo() }
        }
    }
}
