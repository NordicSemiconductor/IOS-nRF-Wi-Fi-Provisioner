//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/06/2022.
//

#if os(macOS)
import AppKit

extension NSAppearance.Name {
    var isDark: Bool {
        self == .darkAqua || self == .vibrantDark || self == .accessibilityHighContrastDarkAqua || self == .accessibilityHighContrastVibrantDark
    }
}

extension NSColor {
    convenience init(rgba: RGBA) {
        self.init(red: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    }
    
    convenience init(light: RGBA, dark: RGBA) {
        self.init(name: nil) { appearance in
            appearance.name.isDark ? NSColor(rgba: dark) : NSColor(rgba: light)
        }
    }
}
#endif
