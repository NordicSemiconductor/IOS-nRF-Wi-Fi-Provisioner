//
//  DeviceSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI

// MARK: - DeviceSection

struct DeviceSection: View {
    
    // MARK: Properties
    
    @EnvironmentObject private var viewModel: DeviceView.ViewModel
    
    // MARK: View
    
    var body: some View {
        Section("Device") {
            HStack {
                NordicLabel("Status", image: "bluetooth")
                
                Spacer()
                
                Text(viewModel.provisioned ? "Provisioned" : "Not Provisioned")
                    .status(viewModel.provisionedState)
            }
        }
    }
}
