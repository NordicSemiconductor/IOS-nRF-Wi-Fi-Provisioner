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

/// Implementation fo `Comparable` protocol for optional.
/// It's supposed that any value is bigger than nil
extension Optional: Comparable where Wrapped: Comparable {
    public static func < (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return false
        case (_?, nil): return false
        case (nil, _?): return true
        case (let a?, let b?): return a < b
        }
    }
    
    public static func > (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return false
        case (_?, nil): return true
        case (nil, _?): return false
        case (let a?, let b?): return a > b
        }
    }
    
    public static func <= (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return false
        case (_?, nil): return false
        case (nil, _?): return true
        case (let a?, let b?): return a <= b
        }
    }
    
    public static func >= (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return false
        case (_?, nil): return true
        case (nil, _?): return false
        case (let a?, let b?): return a >= b
        }
    }
    
    
}
