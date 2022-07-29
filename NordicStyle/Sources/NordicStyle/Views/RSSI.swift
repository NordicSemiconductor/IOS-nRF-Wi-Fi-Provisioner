//
//  File.swift
//  
//
//  Created by Nick Kibysh on 20/07/2022.
//

import SwiftUI

public
protocol RSSI: CaseIterable, Equatable {
    static var good: Self { get }
    static var ok: Self { get }
    static var bad: Self { get }
    static var outOfRange: Self { get }
    static var practicalWorst: Self { get }
}

public
extension RSSI {
    static var allCases: [Self] {
        [.good, .ok, .bad, .outOfRange, .practicalWorst]
    }
}

public
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
        default:
            fatalError("Unknown RSSI value")
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
        default:
            fatalError("Unknown RSSI value")
        }
    }
}
