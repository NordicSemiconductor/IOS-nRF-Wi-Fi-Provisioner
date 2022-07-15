//
//  File.swift
//  
//
//  Created by Nick Kibysh on 14/07/2022.
//

import Foundation

public
struct RSSI {
    let level: Int
    
    public
    enum Signal {
        case good, ok, bad, outOfRange, practicalWorst
    }
    
    public init(level: Int) {
        self.level = level
    }
    
    public
    var signal: Signal {
        switch self.level {
        case 5...: return .outOfRange
        case (-60)...: return .good
        case (-90)...: return .ok
        case (-100)...: return .bad
        default: return .practicalWorst
        }
    }
    
}
