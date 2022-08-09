//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/06/2022.
//

import SwiftUI

public extension ShapeStyle where Self == Color {
    static var nordicBlue: Color { .init(rgba: 0x00a9ce) }
    static var nordicSky: Color { .init(rgba: 0x6ad1e3) }
    static var nordicBlueslate: Color { .init(rgba: 0x0033a0) }
    static var nordicLake: Color { .init(rgba: 0x0077c8) }
    static var nordicGrass: Color { .init(rgba: 0xd0df00) }
    static var nordicSun: Color { .init(rgba: 0xffcd00) }
    static var nordicRed: Color { .init(rgba: 0xee2f4e) }
    static var nordicFall: Color { .init(rgba: 0xf58220) }
    static var nordicLightGrey: Color { .init(rgba: 0xd9e1e2) }
    static var nordicMiddleGrey: Color { .init(rgba: 0x768692) }
    static var nordicDarkGrey: Color { .init(rgba: 0x333f48) }
}

public extension Color {
    static var navigationBarBackground: Color { Color(light: 0x00a9ce, dark: RGBA(0x333F48)) }
}
