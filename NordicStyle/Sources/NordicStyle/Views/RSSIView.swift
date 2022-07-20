//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/07/2022.
//

import SwiftUI

public
struct RSSIView: View {
    let rssi: RSSI
    
    public
    init(rssi: RSSI) {
        self.rssi = rssi
    }
    
    public
    var body: some View {
        RSSIShape(
            filledBarCount: rssi.numberOfBars, totalBarCount: 4
        )
        .fill(rssi.color)
    }
}

struct RSSIView_Previews: PreviewProvider {
    static var previews: some View {
        RSSIView(rssi: RSSI.good)
            .padding()
    }
}
