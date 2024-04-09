//
//  AccessPointSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE

struct AccessPointSection: View {
    let viewModel: DeviceView.ViewModel
    let wifi: WifiInfo?
    
    let showPassword: Bool
    let footer: String?
    var showVolatileMemory: Bool
    
    @Binding var password: String
    @Binding var volatileMemory: Bool
    @Binding var showAccessPointList: Bool
    
    var body: some View {
        Section {
            accessPointSelector
            
            if let wifi {
                additionalInfo(wifi)
            }
            
            if showPassword {
                SecureField("Password", text: $password)
            }
            
            if showVolatileMemory {
                HStack {
                    Text("Volatile Memory")
                    Spacer()
                    Toggle("", isOn: $volatileMemory)
                        .toggleStyle(SwitchToggleStyle(tint: .nordicBlue))
                        .accessibilityIdentifier("volatile_memory_toggle")
                }
            }
        } header: {
            Text("Access Point")
        } footer: {
            footer.map { Text($0) }
        }
    }
    
    @ViewBuilder
    var accessPointSelector: some View {
            VStack {
                HStack {
                    NordicLabel("Access Point", systemImage: "wifi.circle")
                    Spacer()
                    ReversedLabel {
                        Text(wifi?.ssid ?? "Not Selected")
                    } image: {
                        Image(systemName: "chevron.forward")
                    }
                    .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                showAccessPointList = true
            }
            .accessibilityIdentifier("access_point_selector")
    }
    
    @ViewBuilder
    func additionalInfo(_ wifi: WifiInfo) -> some View {
        VStack {
            DetailRow(title: "Channel", details: "\(wifi.channel)")
            DetailRow(title: "BSSID", details: wifi.bssid.description)
            DetailRow(title: "Band", details: wifi.band?.description ?? "Unknown Band")
            DetailRow(title: "Security", details: wifi.auth?.description ?? "Unknown Security")
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
                wifi: wf1,
                showPassword: true,
                footer: "WIFI_NOT_PROVISIONED_FOOTER",
                showVolatileMemory: true,
                password: .constant("qwerty"),
                volatileMemory: .constant(true),
                showAccessPointList: .constant(false)
            )
            
            /*
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                wifiInfo: wf1,
                showPassword: false,
                showFooter: true,
                showVolatileMemory: true,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                wifiInfo: wf2,
                showPassword: true,
                showFooter: false,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                wifiInfo: wf3,
                showPassword: false,
                showFooter: true,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                wifiInfo: wf1,
                showPassword: false,
                showFooter: true,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
            AccessPointSection(
                viewModel: MockDeviceViewModel(deviceId: ""),
                wifiInfo: nil,
                showPassword: false,
                showFooter: true,
                showVolatileMemory: false,
                password: .constant(""),
                volatileMemory: .constant(false),
                showAccessPointList: .constant(false)
            )
             */
            
        }
    }
}
#endif
