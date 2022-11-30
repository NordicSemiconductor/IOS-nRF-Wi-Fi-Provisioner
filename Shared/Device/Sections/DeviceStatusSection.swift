//
//  DeviceStatusSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import Provisioner

struct DeviceStatusSection: View {
    let version: String
    let connectionStatus: String
    let statusProgress: StatusModifier.Status
    let showConnectionStatus: Bool
    let connectionError: ReadableError?
    let ip: String?
    let showIp: Bool
    
    var body: some View {
        Section("Device Status") {
            HStack {
                NordicLabel("Version", systemImage: "wrench.and.screwdriver")
                Spacer()
                Text(version).foregroundColor(.secondary)
            }
            
            if showConnectionStatus {
                VStack {
                    HStack {
                        NordicLabel("Wi-Fi Status", systemImage: "wifi")
                        Spacer()
                        Text(connectionStatus)
                            .status(statusProgress)
                    }
                    if let e = connectionError {
                        HStack {
                            Text(e.message)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            
            HStack {
                NordicLabel("IP Address", systemImage: "network")
                Spacer()
                Text(ip ?? "Unknown").foregroundColor(.secondary)
            }
            .isHidden(!showIp, remove: true)
        }
    }
}

struct DeviceStatusSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                
                /*
                DeviceStatusSection(version: "17", connectionStatus: .disconnected, forceShowProvisionInProgress: false, connectionError: nil,
                                    ip: nil,
                                    provisioned: false
                )
                DeviceStatusSection(version: "17", connectionStatus: .disconnected, forceShowProvisionInProgress: false, connectionError: TitleMessageError(message: "Connection Error"),
                                    ip: nil, provisioned: true)
                DeviceStatusSection(version: "17", connectionStatus: .connected, forceShowProvisionInProgress: false, connectionError: nil, ip: nil, provisioned: true)
                DeviceStatusSection(version: "17", connectionStatus: .connected, forceShowProvisionInProgress: false, connectionError: nil, ip: "192.168.1.1", provisioned: true)
                DeviceStatusSection(version: "17", connectionStatus: .obtainingIp, forceShowProvisionInProgress: false, connectionError: nil, ip: nil, provisioned: true)
                DeviceStatusSection(version: "17", connectionStatus: .disconnected, forceShowProvisionInProgress: true, connectionError: nil, ip: nil, provisioned: true)
                 */
            }
        }
        .tint(.nordicBlue)
    }
}
