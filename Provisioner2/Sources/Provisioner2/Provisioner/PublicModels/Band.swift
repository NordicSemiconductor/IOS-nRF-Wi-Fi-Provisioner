//
//  Band.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

public enum Band: Equatable {
    case any 
    case band24Gh
    case band5Gh
}

extension Band: ProtoConvertible {
    typealias P = Proto.Band
    
    init(proto: Proto.Band) {
        switch proto {
        case .any:
            self = .any
        case .band24Gh:
            self = .band24Gh
        case .band5Gh:
            self = .band5Gh
        }
    }
    
    var proto: Proto.Band {
        switch self {
        case .any:
            return .any
        case .band24Gh:
            return .band24Gh
        case .band5Gh:
            return .band5Gh
        }
    }
}
