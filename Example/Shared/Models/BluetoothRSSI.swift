//
// Created by Nick Kibysh on 29/07/2022.
//

import Foundation
import iOS_Common_Libraries

extension RSSI {

    init(bleLevel: Int) {
        switch bleLevel {
        case 5...: self = .outOfRange
        case (-60)...: self = .good
        case (-90)...: self = .ok
        case (-100)...: self = .bad
        default: self = .practicalWorst
        }
    }

    var isNearby: Bool {
        switch self {
        case .good, .ok: return true
        default: return false // .bad, .outOfRange, .practicalWorst
        }
    }
}
