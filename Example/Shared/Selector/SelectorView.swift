//
//  SelectorView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI

struct SelectorView: View {
    
    var body: some View {
        VStack {
            Text("Select Mode")

            NavigationLink {
                ScannerView(viewModel: ScannerViewModel())
            } label: {
                Text("Provision over BLE")
            }
            .padding()

            NavigationLink {
                ProvisionOverWiFiView()
            } label: {
                Text("Provision over Wi-Fi")
            }
            .padding()
        }
    }
}
