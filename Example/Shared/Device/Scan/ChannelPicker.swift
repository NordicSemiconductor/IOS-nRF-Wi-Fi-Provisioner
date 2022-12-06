//
//  ChannelPicker.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 21/09/2022.
//

import NordicStyle
import NordicWiFiProvisioner
import SwiftUI

struct ChannelPicker: View {
    @State var channels: [AccessPointList.ViewModel.ScanResult]
    @Binding var selectedChannel: String?
    
    var body: some View {
        List(selection: $selectedChannel) {
            Section {
                ForEach(channels, id: \.id) { channel in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Channel \(channel.wifi.channel)")
                                .accessibilityIdentifier("channel_\(channels.firstIndex(of: channel) ?? -1)")
                            Text(channel.wifi.bssid.description)
                                    .font(.caption)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            channel.rssi.map {
                                RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: $0))
                                    .frame(maxWidth: 30, maxHeight: 20)
                            }
                            Text(channel.wifi.band?.description ?? "? GHz")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityIdentifier("channel_selector_\(channels.firstIndex(of: channel) ?? -1)")
                    .tag(Optional(channel))
                    .accessibilityIdentifier("accid")
                }
            } header: {
                Text("Select Channel")
            }
        }
        .navigationTitle(selectedChannel ?? "Channel")
    }
}

#if DEBUG
struct ChannelPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelPicker(
                channels: [
                    WifiInfo(ssid: "Home", bssid: .mac2, band: .band24Gh, channel: 1, auth: .open),
                    WifiInfo(ssid: "Office", bssid: .mac1, band: .band5Gh, channel: 2, auth: .wep),
                    WifiInfo(ssid: "Guest", bssid: .mac3, band: .band24Gh, channel: 3, auth: .wpa2Psk)
                ].map { AccessPointList.ViewModel.ScanResult(wifi: $0, rssi: Int.random(in: (-40)...(-100))) }, selectedChannel: .constant(nil)
            )
            .navigationTitle("Office Wi-Fi")
        }
    }
}
#endif
