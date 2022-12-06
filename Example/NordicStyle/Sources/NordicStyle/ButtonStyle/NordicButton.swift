//
//  NordicButtonStyle.swift
//  
//
//  Created by Nick Kibysh on 30/06/2022.
//

import SwiftUI

@available(iOS 15.0, *)
// button style with nordicBlue color and rounded corners
public struct NordicButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        #if os(iOS)
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? .nordicLake : .secondary)
            .foregroundColor(configuration.isPressed ? .init(white: 0.95) : .white)
            .cornerRadius(4)
            .shadow(radius: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        #else
        configuration.label.padding()
        #endif
    }
}

@available(iOS 15.0, *)
// button style with nordicBlue color and rounded corners
public struct DistructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        #if os(iOS)
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? .red : .secondary)
            .foregroundColor(configuration.isPressed ? .init(white: 0.95) : .white)
            .cornerRadius(4)
            .shadow(radius: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        #else
        configuration.label.padding()
        #endif
    }
}

@available(iOS 15.0, *)
// button style with nordicBlue color and rounded corners
public struct HollowDistructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        #if os(iOS)
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(isEnabled ? .red : .secondary)
            .overlay(RoundedRectangle(cornerRadius: 4)
                .stroke(isEnabled ? .red : .secondary, lineWidth: 2)
            )
            .shadow(radius: 0.2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            
        #else
        configuration.label.padding()
        #endif
    }
}
