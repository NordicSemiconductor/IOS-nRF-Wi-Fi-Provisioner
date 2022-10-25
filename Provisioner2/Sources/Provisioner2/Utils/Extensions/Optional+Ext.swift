//
//  File.swift
//  
//
//  Created by Nick Kibysh on 25/10/2022.
//

import Foundation

extension Optional {
    var isNil: Bool {
        switch self {
        case .some: return false
        case .none: return true
        }
    }
    
    var isSome: Bool {
        return !isNil
    }
}
