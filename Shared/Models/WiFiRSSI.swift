//
// Created by Nick Kibysh on 29/07/2022.
//

import Foundation
import NordicStyle

enum WiFiRSSI: RSSI {
    case good
    case ok
    case bad
    case outOfRange
    case practicalWorst

    init(level: Int) {
        switch level {
        case 5...: self = .outOfRange
        case (-60)...: self = .good
        case (-90)...: self = .ok
        case (-100)...: self = .bad
        default: self = .practicalWorst
        }
    }
}