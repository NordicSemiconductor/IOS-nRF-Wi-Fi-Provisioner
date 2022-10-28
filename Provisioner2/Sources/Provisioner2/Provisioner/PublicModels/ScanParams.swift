//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

protocol ScanParams {
    var band: Band? { get set }
    var passive: Bool? { get set }
    var periodMs: UInt? { get set }
    var groupChannels: UInt? { get set }
}

extension Envelope: ScanParams where P == Proto.ScanParams {
    var band: Band? {
        get {
            model.hasBand ? Band(proto: model.band) : nil
        }
        set {
            (newValue?.proto).map { model.band = $0 }
        }
    }
    
    var passive: Bool? {
        get {
            model.hasPassive ? model.passive : nil
        }
        set {
            newValue.map { model.passive = $0 }
        }
    }
    
    var periodMs: UInt? {
        get {
            model.hasPeriodMs ? UInt(model.periodMs) : nil
        }
        set {
            newValue.map { UInt32($0) }.map { model.periodMs = $0 }
        }
    }
    
    var groupChannels: UInt? {
        get {
            model.hasGroupChannels ? UInt(model.groupChannels) : nil
        }
        set {
            newValue.map { UInt32($0) }.map { model.groupChannels = $0 }
        }
    }
    
    
}
