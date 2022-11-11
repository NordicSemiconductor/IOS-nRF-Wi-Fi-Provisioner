//
//  DeviceSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI

struct DeviceSection: View {
    let provisioned: Bool
    
    var body: some View {
        Section("Device") {
            HStack {
                NordicLabel("Status", image: "bluetooth")
                
                Spacer()
                Text(provisioned ? "Provisioned  ✓" : "Not Provisioned")
                    .foregroundColor(provisioned ? .green : .secondary)
            }
        }
    }
}

struct DeviceSection_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DeviceSection(provisioned: true)
            DeviceSection(provisioned: false)
        }
    }
}
