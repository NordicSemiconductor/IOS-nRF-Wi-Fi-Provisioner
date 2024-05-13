//
//  nRF_Wi_Fi_ProvisionerApp.swift
//  Shared
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE
import NordicWiFiProvisioner_SoftAP
import Network

@main
struct nRF_Wi_Fi_ProvisionerApp: App {
    
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var vmFactory = DeviceViewModelFactory()
    
    init() {
        MockManager.emulateDevices()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SelectorView()
                    .environmentObject(vmFactory)
                    .navigationTitle("nRF Wi-Fi Provisioner")
                    .toolbar {
                        Button("", systemImage: "info.circle") {
                            viewModel.showStartInfo = true
                        }
                    }
            }
            .sheet(isPresented: $viewModel.showStartInfo) {
                IntroView(show: $viewModel.showStartInfo,
                          dontShowAgain: $viewModel.dontShowAgain)
            }
        }
    }
}
