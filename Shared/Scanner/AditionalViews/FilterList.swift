//
//  FilterList.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 18/07/2022.
//

import SwiftUI
import NordicStyle

struct FilterList: View {
    @Binding var uuid: Bool
    @Binding var nearby: Bool
    @Binding var named: Bool
    
    var body: some View {
        HStack {
            Toggle(isOn: $uuid) {
                Text("UUID")
                    .tint(.nordicBlue)
            }
            .toggleStyle(.button)
            .tint(.nordicBlue)
            
            Spacer()
            
            Toggle(isOn: $nearby) {
                Text("Nearby")
                    .tint(.nordicBlue)
            }
            .toggleStyle(.button)
            .tint(.nordicBlue)
            
            Spacer()
            
            Toggle(isOn: $named) {
                Text("Named")
                    .tint(.nordicBlue)
            }
            .toggleStyle(.button)
            .tint(.nordicBlue)
        }
    }
}

struct FilterList_Previews: PreviewProvider {
    static var previews: some View {
        FilterList(uuid: .constant(true), nearby: .constant(false), named: .constant(true))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}
