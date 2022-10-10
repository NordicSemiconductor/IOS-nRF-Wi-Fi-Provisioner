//
//  ChannelPicker.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 21/09/2022.
//

import NordicStyle
import Provisioner
import SwiftUI

struct ChannelPicker: View {
    @State var channels: [AccessPoint]
    @Binding var selectedChannel: String?
    
    var body: some View {
        List(selection: $selectedChannel) {
            Section {
                ForEach(channels, id: \.id) { channel in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Channel \(channel.channel)")
                                .accessibilityIdentifier("channel_\(channels.firstIndex(of: channel) ?? -1)")
                            Text(channel.bssid)
                                    .font(.caption)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: channel.rssi))
                                    .frame(maxWidth: 30, maxHeight: 20)
                            Text(channel.frequency.stringValue.description)
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
                    AccessPoint(
                        ssid: "Home",
                        bssid: "bssid",
                        id: "id1",
                        isOpen: false,
                        channel: 1,
                        rssi: -40,
                        frequency: ._2_4GHz
                    ),
                    AccessPoint(
                        ssid: "Guest",
                        bssid: "bssid",
                        id: "id2",
                        isOpen: true,
                        channel: 1,
                        rssi: -50,
                        frequency: ._5GHz
                    ),
                    AccessPoint(
                        ssid: "Office",
                        bssid: "bssid",
                        id: "id3",
                        isOpen: false,
                        channel: 1,
                        rssi: -60,
                        frequency: .any
                    )
                ], selectedChannel: .constant(nil)
            )
            .navigationTitle("Office Wi-Fi")
        }
    }
}
#endif
