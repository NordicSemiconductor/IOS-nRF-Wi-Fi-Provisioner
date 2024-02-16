//
//  nRF_Wi_Fi_ProvisionerApp.swift
//  Shared
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE

@main
struct nRF_Wi_Fi_ProvisionerApp: App {
    
    init() {
        MockManager.emulateDevices()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SelectorView()
                    .navigationTitle("nRF Wi-Fi Provisioner")
            }
        }
    }
}
