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
    
    @State private var mode: SelectorView.Mode?
    
    init() {
        MockManager.emulateDevices()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SelectorView()
                    .navigationTitle("Chose")
            }
            /*
            switch mode {
            case .none:
                SelectorView(selected: $mode)
            case .provisionOverBle:
                NavigationView {
                    ScannerView(viewModel: ScannerViewModel())
                        .environmentObject(DeviceViewModelFactory())
                        .onFirstAppear {
                            
                        }
                }
            case .provisionOverWifi:
                Text("To-Do")
            }
             */
        }
    }
}
