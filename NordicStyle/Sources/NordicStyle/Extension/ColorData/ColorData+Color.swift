//
//  ColorData+Color.swift
//  
//
//  Created by Nick Kibysh on 28/06/2022.
//

import SwiftUI

#if os(macOS)
typealias SysColor = NSColor
#elseif os(iOS)
typealias SysColor = UIColor
#endif

extension Color {
    init(light: RGBA, dark: RGBA) {
        self.init(SysColor(light: light, dark: dark))
    }
    
    init(rgba: RGBA) {
        self.init(SysColor(rgba: rgba))
    }
}
