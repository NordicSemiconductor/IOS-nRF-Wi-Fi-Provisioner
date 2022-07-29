//
//  nRF_Wi_Fi_ProvisionerApp.swift
//  Shared
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI

@main
struct nRF_Wi_Fi_ProvisionerApp: App {
    var body: some Scene {
        WindowGroup {
            ScannerView(viewModel: ScannerViewModel())
                .environmentObject(DeviceViewModelFactory())
        }
    }
}
