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
                
                Section("About") {
                    Text("""
                    nRF Wi-Fi Provisioner can be used to securely provision nRF700x devices to Wi-Fi networks over Bluetooth LE, Wi-Fi (SoftAP) or NFC. Some transport methods allow provisioning verification and re-provisioning.
                    """)
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
