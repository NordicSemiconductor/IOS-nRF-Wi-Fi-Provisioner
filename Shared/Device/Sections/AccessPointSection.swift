//
//  AccessPointSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import Provisioner2

struct AccessPointSection: View {
    let viewModel: DeviceView.ViewModel
    
    let inProgress: Bool
    let wifiInfo: WifiInfo?
    
    let passwordRequired: Bool
    let showFooter: Bool
    var showVolatileMemory: Bool
    
    @Binding var password: String
    @Binding var volatileMemory: Bool
    @Binding var showAccessPointList: Bool
    
    var body: some View {
        Section {
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
        } header: {
            Text("Access Point")
        } footer: {
            if wifiInfo == nil {
                Text("WIFI_NOT_PROVISIONED_FOOTER")
            } else if wifiInfo != nil && showFooter {
                Text("PROVISIONED_DEVICE_FOOTER")
            } else {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    var accessPointSelector: some View {
        NavigationLink(isActive: $showAccessPointList) {
            AccessPointList(provisioner: viewModel.provisioner, wifiSelection: viewModel)
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
            DetailRow(title: "Channel", details: "\(wifiInfo.channel)")
            DetailRow(title: "BSSID", details: "\(wifiInfo.bssid)")
            wifiInfo.band.map { DetailRow(title: "Band", details: "\($0)") }
            wifiInfo.auth.map { DetailRow(title: "Security", details: "\($0)") }
        }
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
                viewModel: MockDeviceViewModel(deviceId: ""),
                inProgress: false,
                wifiInfo: wf1,
                passwordRequired: false,
                showFooter: true,
                showVolatileMemory: true,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                inProgress: false,
                wifiInfo: wf2,
                passwordRequired: true,
                showFooter: false,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                inProgress: false,
                wifiInfo: wf3,
                passwordRequired: false,
                showFooter: true,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                inProgress: false,
                wifiInfo: wf1,
                passwordRequired: false,
                showFooter: true,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                inProgress: false,
                wifiInfo: nil,
                passwordRequired: false,
                showFooter: true,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
        }
    }
}
#endif
