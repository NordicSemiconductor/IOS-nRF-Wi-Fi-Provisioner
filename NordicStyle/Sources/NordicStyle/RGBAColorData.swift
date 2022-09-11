//
//  RGBAColorData.swift
//  
//
//  Created by Nick Kibysh on 28/06/2022.
//

import Foundation

struct RGBA {
    private var rgb: RGB
    var a: Double
    var r: Double { rgb.r }
    var g: Double { rgb.g }
    var b: Double { rgb.b }
    
    init(_ hex: Int, alpha: Double = 1) {
        rgb = RGB(hex)
        a = alpha
    }
    
    init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.rgb = RGB(r: r, g: g, b: b)
        self.a = a
    }
    
    init(r: Int, g: Int, b: Int, a: Double = 1) {
        self.rgb = RGB(r: r, g: g, b: b)
        self.a = a
    }
}

struct RGB {
    var r: Double
    var g: Double
    var b: Double
    
    init(_ hex: Int) {
        let r = (hex & 0xff_00_00) / 0x1_00_00
        let g = (hex & 0xff_00) / 0x1_00
        let b = (hex & 0xff)
        
        self.r = Double(r) / Double(0xff)
        self.g = Double(g) / Double(0xff)
        self.b = Double(b) / Double(0xff)
    }
    
    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    init(r: Int, g: Int, b: Int, a: Double = 1) {
        let f: (Int) -> Double = {
            Double($0) / 255.0
        }
        
        self.r = f(r)
        self.g = f(g)
        self.b = f(b)
    }
}

extension RGBA: ExpressibleByIntegerLiteral {
    init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}
