//
// Created by Nick Kibysh on 27/07/2022.
//

import Foundation

extension AuthMode {
    var isOpen: Bool {
        switch self {
        case .open:
            return true
        default:
            return false
        }
    }
}