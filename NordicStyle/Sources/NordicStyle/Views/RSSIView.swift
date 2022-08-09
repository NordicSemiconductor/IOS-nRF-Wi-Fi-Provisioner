//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/07/2022.
//

import SwiftUI

public
struct RSSIView<R: RSSI>: View {
    let rssi: R
    
    public
    init(rssi: R) {
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

#if DEBUG
struct RSSIView_Previews: PreviewProvider {
    private enum PreviewRSSI: RSSI {
        case good
        case ok
        case bad
        case outOfRange
        case practicalWorst
    }

    static var previews: some View {
        RSSIView<PreviewRSSI>(rssi: .good)
            .padding()
    }
}
#endif
