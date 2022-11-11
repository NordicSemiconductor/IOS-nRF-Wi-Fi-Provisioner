//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

public struct ScanParams {
    var band: Band?
    var passive: Bool?
    var periodMs: UInt?
    var groupChannels: UInt?
    
    public init(band: Band? = nil, passive: Bool? = nil, periodMs: UInt? = nil, groupChannels: UInt? = nil) {
        self.band = band
        self.passive = passive
        self.periodMs = periodMs
        self.groupChannels = groupChannels
    }
}

extension ScanParams: ProtoConvertible {
    init(proto: Proto.ScanParams) {
        self.band = proto.hasBand ? Band(proto: proto.band) : nil
        self.passive = proto.hasPassive ? proto.passive : nil
        self.periodMs = proto.hasPeriodMs ? UInt(proto.periodMs) : nil
        self.groupChannels = proto.hasGroupChannels ? UInt(proto.groupChannels) : nil
    }
    
    var proto: Proto.ScanParams {
        var proto = Proto.ScanParams()
        band.map { proto.band = $0.proto }
        passive.map { proto.passive = $0 }
        periodMs.map { proto.periodMs = UInt32($0) }
        groupChannels.map { proto.groupChannels = UInt32($0) }
        return proto
    }
    
}
