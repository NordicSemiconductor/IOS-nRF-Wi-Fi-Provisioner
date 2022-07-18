//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/07/2022.
//

import SwiftUI
import nRF_BLE

public
struct RSSIView: View {
    let rssi: RSSI
    
    public var body: some View {
        RSSIShape(
            filledBarCount: rssi.numberOfBars, totalBarCount: 4
        )
        .fill(rssi.color)
    }
}

extension RSSI {
    var color: Color {
        switch self.signal {
        case .good:
            return .green
        case .ok:
            return .yellow
        case .bad:
            return .orange
        case .outOfRange:
            return .red
        case .practicalWorst:
            return .red
        }
    }
    
    var numberOfBars: Int {
        switch signal {
        case .good:
            return 4
        case .ok:
            return 3
        case .bad:
            return 2
        case .outOfRange:
            return 0
        case .practicalWorst:
            return 1
        }
    }
}

struct RSSIView_Previews: PreviewProvider {
    static var previews: some View {
        RSSIView(rssi: RSSI(level: 0))
            .padding()
    }
}
