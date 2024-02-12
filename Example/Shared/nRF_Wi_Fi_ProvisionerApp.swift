//
//  nRF_Wi_Fi_ProvisionerApp.swift
//  Shared
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI
import NordicWiFiProvisioner

@main
struct nRF_Wi_Fi_ProvisionerApp: App {
    
    init() {
        MockManager.emulateDevices()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ScannerView(viewModel: ScannerViewModel())
                    .environmentObject(DeviceViewModelFactory())
                    .onFirstAppear {
                        
                    }
            }
        }
                
    }
}
