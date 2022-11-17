//
//  DeviceStatusSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import Provisioner2

struct DeviceStatusSection: View {
    let version: String
    let connectionStatus: ConnectionState?
    let forceShowProvisionInProgress: Bool
    let provisioningError: ReadableError?
    let ip: String?
    
    var body: some View {
        Section("Device Status") {
            HStack {
                NordicLabel("Version", systemImage: "wrench.and.screwdriver")
                Spacer()
                Text(version).foregroundColor(.secondary)
            }
            
            VStack {
                HStack {
                    NordicLabel("Wi-Fi Status", systemImage: "wifi")
                    Spacer()
                    ReversedLabel {
                        Text(connectionStatus?.description ?? "Unprovisioned")
                    } image: {
                        StatusIndicatorView(status: connectionStatus, forceProgress: forceShowProvisionInProgress)
                    }
                    .status(connectionStatus ?? .disconnected)
                }
                if let e = provisioningError {
                    HStack {
                        Text(e.message)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            
            if let ip {
                HStack {
                    NordicLabel("IP Address", systemImage: "network")
                    Spacer()
                    Text(ip).foregroundColor(.secondary)
                }
            }
        }
    }
}

struct DeviceStatusSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                DeviceStatusSection(version: "17", connectionStatus: .disconnected, forceShowProvisionInProgress: false, provisioningError: nil, ip: nil)
                DeviceStatusSection(version: "17", connectionStatus: .disconnected, forceShowProvisionInProgress: false, provisioningError: TitleMessageError(message: "Connection Error"), ip: nil)
                DeviceStatusSection(version: "17", connectionStatus: .connected, forceShowProvisionInProgress: false, provisioningError: nil, ip: nil)
                DeviceStatusSection(version: "17", connectionStatus: .connected, forceShowProvisionInProgress: false, provisioningError: nil, ip: "192.168.1.1")
                DeviceStatusSection(version: "17", connectionStatus: .obtainingIp, forceShowProvisionInProgress: false, provisioningError: nil, ip: nil)
                DeviceStatusSection(version: "17", connectionStatus: .disconnected, forceShowProvisionInProgress: true, provisioningError: nil, ip: nil)
            }
        }
        .tint(.nordicBlue)
    }
}
