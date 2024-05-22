/*
* Copyright (c) 2022, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

/// Scanning parameters.
public struct ScanParams {
    /// Wi-Fi frequency band. 
    ///
    /// It's used as a parameter for the scanning.
    public struct Band: OptionSet {
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let band24Gh = Band(rawValue: 1 << 0)
        public static let band5Gh =  Band(rawValue: 1 << 1)
        
        public static let `any`: Band = [.band24Gh, .band5Gh]
    }

    public var band: Band
    public var passive: Bool?
    public var periodMs: UInt?
    public var groupChannels: UInt?
    
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
