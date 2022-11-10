//
//  AccessPointSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import Provisioner2

struct AccessPointSection: View {
    let inProgress: Bool
    let wifiInfo: WifiInfo?
    
    let passwordRequired: Bool
    var showVolatileMemory: Bool
    
    @Binding var password: String
    @Binding var volatileMemory: Bool
    @Binding var showAccessPointList: Bool
    
    var body: some View {
        Section("Access Point") {
            accessPointSelector
            
            if let wifiInfo {
                additionalInfo(wifiInfo: wifiInfo)
            }
            
            if passwordRequired {
                SecureField("Password", text: $password)
                    .disabled(inProgress)
            }
            
            if showVolatileMemory {
                HStack {
                    Text("Volatile Memory")
                    Spacer()
                    Toggle("", isOn: $volatileMemory)
                        .toggleStyle(SwitchToggleStyle(tint: .nordicBlue))
                }
                .disabled(inProgress)
            }
        }
    }
    
    @ViewBuilder
    var accessPointSelector: some View {
        NavigationLink(isActive: $showAccessPointList) {
//                AccessPointList(viewModel: AccessPointListViewModel(provisioner: viewModel.provisioner, accessPointSelection: viewModel))
            EmptyView()
        } label: {
            VStack {
                HStack {
                    NordicLabel("Access Point", systemImage: "wifi.circle")
                    Spacer()
                    Text(wifiInfo?.ssid ?? "Not Selected")
                        .foregroundColor(.secondary)
                }
            }
            .disabled(inProgress)
        }
        .accessibilityIdentifier("access_point_selector")
        .disabled(inProgress)
    }
    
    @ViewBuilder
    func additionalInfo(wifiInfo: WifiInfo) -> some View {
        VStack {
            wifiInfo.channel.map { DetailRow(title: "Channel", details: "\($0)") }
            wifiInfo.bssid.map { DetailRow(title: "BSSID", details: "\($0)") }
            wifiInfo.band.map { DetailRow(title: "Band", details: "\($0)") }
            wifiInfo.auth.map { DetailRow(title: "Security", details: "\($0)") }
            /*
            if ap.rssi < 0 {
                HStack {
                    DetailRow(title: "Signal Strength", details: "\(ap.rssi) dBm")
                    RSSIView(rssi: WiFiRSSI(level: ap.rssi))
                        .frame(maxWidth: 15, maxHeight: 16)
                        .accessibilityIdentifier("rssi_view")
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(maxHeight: 8)
            }
             */
        }
        /*
        HStack {
            
            
            /*
            
            VStack(alignment: .leading) {
                Text("Channel \(ap.channel)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(ap.bssid)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Text(ap.frequency.stringValue)
                .foregroundColor(.secondary)
            if ap.rssi != 0 {
                RSSIView(rssi: WiFiRSSI(level: ap.rssi))
                    .frame(maxWidth: 30, maxHeight: 16)
                    .accessibilityIdentifier("rssi_view")
            }
             */
        }
         */
    }
}

private struct DetailRow: View {
    let title: String
    let details: String
    
    var body: some View {
        HStack {
            ReversedLabel {
                Text(title)
                    .font(.caption)
            } image: {
                EmptyView()
            }

            Spacer()
            Text(details)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: 12)
    }
}

#if DEBUG
private extension MACAddress {
    static func random() -> MACAddress {
        var arr: [UInt8] = []
        for _ in 0..<6 {
            arr.append(UInt8.random(in: 0...0xFF))
        }
        let data = Data(arr)
        return MACAddress(data: data)!
    }
}

struct AccessPointSection_Previews: PreviewProvider {
    static let wf1 = WifiInfo(ssid: "Open", bssid: MACAddress.random(), band: .band24Gh, channel: 1, auth: .open)
    static let wf2 = WifiInfo(ssid: "WPA 2", bssid: MACAddress.random(), band: .band5Gh, channel: 2, auth: .wpa2Psk)
    static let wf3 = WifiInfo(ssid: "wpa3Psk", bssid: MACAddress.random(), band: .band24Gh, channel: 3, auth: .wpa3Psk)
    
    static var previews: some View {
        Form {
            AccessPointSection(
                inProgress: false,
                wifiInfo: wf1,
                passwordRequired: false,
                showVolatileMemory: true,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                inProgress: false,
                wifiInfo: wf2,
                passwordRequired: true,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                inProgress: false,
                wifiInfo: wf3,
                passwordRequired: false,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                inProgress: false,
                wifiInfo: wf1,
                passwordRequired: false,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
        }
    }
}
#endif
