//
// Created by Nick Kibysh on 29/07/2022.
//

import Foundation
import iOS_Common_Libraries

extension RSSI {

    init(wifiLevel: Int) {
        switch wifiLevel {
        case 5...: self = .outOfRange
        case (-60)...: self = .good
        case (-90)...: self = .ok
        case (-100)...: self = .bad
        default: self = .practicalWorst
        }
    }
}
