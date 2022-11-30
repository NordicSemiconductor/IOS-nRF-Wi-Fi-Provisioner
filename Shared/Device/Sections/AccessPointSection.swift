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
    
    let ssid: String
    let bssid: String?
    let band: String?
    let channel: String?
    let auth: String?
    
    let showPassword: Bool
    let footer: String?
    var showVolatileMemory: Bool
    
    @Binding var password: String
    @Binding var volatileMemory: Bool
    @Binding var showAccessPointList: Bool
    
    var body: some View {
        Section {
            accessPointSelector
            
            if !([bssid, band, channel, auth].compactMap { $0 }.isEmpty) {
                additionalInfo()
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
                }
            }
        } header: {
            Text("Access Point")
        } footer: {
            footer.map { Text($0) }
            /*
            if wifiInfo == nil {
                Text("WIFI_NOT_PROVISIONED_FOOTER")
            } else if wifiInfo != nil && showFooter {
                Text("PROVISIONED_DEVICE_FOOTER")
            }
             */
        }
    }
    
    @ViewBuilder
    var accessPointSelector: some View {
            VStack {
                HStack {
                    NordicLabel("Access Point", systemImage: "wifi.circle")
                    Spacer()
                    ReversedLabel {
                        Text(ssid)
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
    func additionalInfo() -> some View {
        VStack {
            channel.map { DetailRow(title: "Channel", details: $0) }
            bssid.map { DetailRow(title: "BSSID", details: $0) }
            band.map { DetailRow(title: "Band", details: $0) }
            auth.map { DetailRow(title: "Security", details: $0) }
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
                ssid: wf1.ssid,
                bssid: wf1.bssid.description,
                band: wf1.band!.description,
                channel: "\(wf1.channel)",
                auth: wf1.auth!.description,
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
