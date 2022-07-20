//
//  File.swift
//  
//
//  Created by Nick Kibysh on 20/07/2022.
//

import SwiftUI

public enum RSSI {
    case good, ok, bad, practicalWorst, outOfRange
}

extension RSSI {
    var color: Color {
        switch self {
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
        switch self {
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
