//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

public struct ScanParams {
    public struct Band: OptionSet {
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let band24Gh = Band(rawValue: 1 << 0)
        public static let band5Gh =  Band(rawValue: 1 << 1)
        
        public static let `any`: Band = [.band24Gh, .band5Gh]
    }
    
    var band: Band
    var passive: Bool?
    var periodMs: UInt?
    var groupChannels: UInt?
    
    public init(band: Band = .any, passive: Bool? = nil, periodMs: UInt? = nil, groupChannels: UInt? = nil) {
        self.band = band
        self.passive = passive
        self.periodMs = periodMs
        self.groupChannels = groupChannels
    }
}

extension ScanParams.Band: ProtoConvertible {
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
        default:
            fatalError()
        }
    }
}

extension ScanParams: ProtoConvertible {
    init(proto: Proto.ScanParams) {
        self.band = proto.hasBand ? Band(proto: proto.band) : .any
        
        self.passive = proto.hasPassive ? proto.passive : nil
        self.periodMs = proto.hasPeriodMs ? UInt(proto.periodMs) : nil
        self.groupChannels = proto.hasGroupChannels ? UInt(proto.groupChannels) : nil
    }
    
    var proto: Proto.ScanParams {
        var proto = Proto.ScanParams()
        proto.band = band.proto
        passive.map { proto.passive = $0 }
        periodMs.map { proto.periodMs = UInt32($0) }
        groupChannels.map { proto.groupChannels = UInt32($0) }
        return proto
    }
    
}
