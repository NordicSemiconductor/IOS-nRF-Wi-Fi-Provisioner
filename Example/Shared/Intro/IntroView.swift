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
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var viewModel: AppViewModel
    
    // MARK: View
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Image("nRF70-Series-nobg")
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
                    Label("[nRF700x-powered device](https://nordicsemi.no)", systemImage: "cpu")
                    
                    Label("Provisioning firmware corresponding to selected method flashed & running on Device.", systemImage: "checklist.checked")
                    
                    Label("Device powered ON and in range.", systemImage: "bolt.fill")
                }
                .listRowSeparator(.hidden)
                
                Button("START_PROVISIONING_BTN") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .accessibilityIdentifier("start_provisioning_btn")
            }
            .navigationTitle("Welcome")
            .onAppear {
                viewModel.introViewShown = true
            }
        }
    }
}
