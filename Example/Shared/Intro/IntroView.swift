//
//  IntroView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - IntroView

struct IntroView: View {
    
    // MARK: Properties
    
    @State private var animationAmount = 1.0
    @State private var selection: Int? = nil
    
    @StateObject var viewModel = IntroViewModel()
    
    @Binding var show: Bool
    
    // MARK: View
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Image(viewModel.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 180)
                        .centered()
                    
                    Text("nRF Wi-Fi Provisioner")
                        .font(.title)
                        .centered()
                    
                    Text("Version: \(viewModel.version)")
                        .font(.caption)
                        .centered()
                }
                .listRowSeparator(.hidden)
                
                Section("Features") {
                    Label("Provision of a device over BLE (Bluetooth Low Energy), Wi-Fi (Access Point) or NFC (Near-Field Communication)", systemImage: "smallcircle.filled.circle")
                    
                    Label("(Optionally) Verify correct provisioning of the device.", systemImage: "smallcircle.filled.circle")
                    
                    Label("Re-provision already provisioned devices to an alternate network.", systemImage: "smallcircle.filled.circle")
                }
                .listRowSeparator(.hidden)
                 
                Section("Requirements") {
                    Label("[nRF700x-powered device](https://nordicsemi.no)", systemImage: "target")
                    
                    Label("Corresponding provisioning application running on device (each provisioning method requires a specific firmware)", systemImage: "target")
                    
                    Label("Make sure the device is powered ON, in range and correct firmware is flashed.", systemImage: "exclamationmark.triangle")
                    .labeledContentStyle(.accented)
                }
                .bold()
                .listRowSeparator(.hidden)
                
                Button("START_PROVISIONING_BTN") {
                    show = false
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .accessibilityIdentifier("start_provisioning_btn")
            }
            .navigationTitle("Welcome")
            .onAppear { try? viewModel.readInfo() }
        }
    }
}
