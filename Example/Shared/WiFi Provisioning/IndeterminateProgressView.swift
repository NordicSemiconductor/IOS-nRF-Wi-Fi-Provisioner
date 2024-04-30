//
//  IndeterminateProgressView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 26/4/24.
//

import SwiftUI

// MARK: - IndeterminateProgressView

/**
 Source: https://matthewcodes.uk/articles/indeterminate-linear-progress-view/
 */
struct IndeterminateProgressView: View {
    
    // MARK: Properties
    
    @State private var width: CGFloat = 0
    @State private var offset: CGFloat = 0
    @Environment(\.isEnabled) private var isEnabled

    // MARK: View
    
    var body: some View {
        Rectangle()
            .foregroundColor(.gray.opacity(0.15))
            .readWidth()
            .overlay(
                Rectangle()
                    .foregroundColor(Color.accentColor)
                    .frame(width: self.width * 0.26, height: 6)
                    .clipShape(Capsule())
                    .offset(x: -self.width * 0.6, y: 0)
                    .offset(x: self.width * 1.2 * self.offset, y: 0)
                    .animation(.default.repeatForever().speed(0.265), value: self.offset)
                    .onAppear{
                        withAnimation {
                            self.offset = 1
                        }
                    }
            )
            .clipShape(Capsule())
            .opacity(self.isEnabled ? 1 : 0)
            .animation(.default, value: self.isEnabled)
            .frame(height: 6)
            .onPreferenceChange(WidthPreferenceKey.self) { width in
                self.width = width
            }
    }
}

// MARK: - WidthPreferenceKey

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - ReadWidthModifier

private struct ReadWidthModifier: ViewModifier {
    
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: WidthPreferenceKey.self, value: geometry.size.width)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

// MARK: - View.readWidth()

extension View {
    
    func readWidth() -> some View {
        self.modifier(ReadWidthModifier())
    }
}
