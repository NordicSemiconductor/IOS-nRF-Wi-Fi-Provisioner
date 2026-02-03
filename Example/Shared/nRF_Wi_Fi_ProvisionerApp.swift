//
//  nRF_Wi_Fi_ProvisionerApp.swift
//  Shared
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE
import iOS_Common_Libraries

@main
struct nRF_Wi_Fi_ProvisionerApp: App {
    
    // MARK: Private Properties
    
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var vmFactory = DeviceViewModelFactory()
    
    // MARK: Init
    
    init() {
        MockManager.emulateDevices()
    }
    
    // MARK: View
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SelectorView()
                    .environmentObject(viewModel)
                    .environmentObject(vmFactory)
                    .navigationTitle("nRF Wi-Fi Provisioner")
            }
            .sheet(isPresented: $viewModel.showStartInfo) {
                IntroView()
                    .environmentObject(viewModel)
            }
        }
    }
}
