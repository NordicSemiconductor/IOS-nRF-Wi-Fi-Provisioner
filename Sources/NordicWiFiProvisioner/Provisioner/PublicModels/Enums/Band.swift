//
//  Band.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

public enum Band: Equatable {
    case band24Gh
    case band5Gh
}

extension Band: CustomStringConvertible {
    public var description: String {
        switch self {
        case .band24Gh:
            return "2.4 GHz"
        case .band5Gh:
            return "5 GHz"
        }
    }
}

extension Band: ProtoConvertible {
    typealias P = Proto.Band
    
    init(proto: Proto.Band) {
        switch proto {
        case .any:
            fatalError("`any` is an internal parameter for `ScanParams` structure")
        case .band24Gh:
            self = .band24Gh
        case .band5Gh:
            self = .band5Gh
        }
    }
    
    var proto: Proto.Band {
        switch self {
        case .band24Gh:
            return .band24Gh
        case .band5Gh:
            return .band5Gh
        }
    }
}
