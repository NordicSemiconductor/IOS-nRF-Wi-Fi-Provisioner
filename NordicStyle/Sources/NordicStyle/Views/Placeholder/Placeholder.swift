//
//  SwiftUIView.swift
//  
//
//  Created by Nick Kibysh on 19/07/2022.
//

import SwiftUI

struct EmptyViewContainer: View {
    var body: some View {
        EmptyView()
    }
}

public
struct Placeholder<Action>: View where Action: View {
    public let text: String?
    public let image: Image
    public let message: String?
    public let action: Action?

    public init(text: String? = nil, message: String? = nil, image: String, action: () -> Action) {
        self.text = text
        self.message = message
        self.image = Image(image)
        self.action = action()
    }

    public init(text: String? = nil, message: String? = nil, image: Image, action: () -> Action) {
        self.text = text
        self.message = message
        self.image = image
        self.action = action()
    }
    
    public var body: some View {
        VStack {
            if #available(iOS 15.0, *) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.nordicBlue)
                    .frame(maxWidth: 200, maxHeight: 250)
            } else {
                // Fallback on earlier versions
            }
            
            if let t = text {
                Spacer()
                    .frame(height: 24)
                
                Text(t)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 250)
            }

            if let m = message {
                Spacer()
                    .frame(height: 24)
                Text(m)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 300)
            }

            if let actionView = action {
                Spacer()
                    .frame(height: 24)
                actionView
            }
        }
    }
}

extension Placeholder where Action == EmptyView {
    public init(text: String? = nil, message: String? = nil, image: String) {
        self.text = text
        self.message = message
        self.image = Image(image)
        self.action = nil
    }

    public init(text: String? = nil, message: String? = nil, systemImage: String) {
        self.text = text
        self.message = message
        self.image = Image(systemName: systemImage)
        self.action = nil
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                Placeholder(
                    text: "Here's some message we want to show to the user",
                    systemImage: "wifi"
                )
                .padding()
                .previewDisplayName("Text and Image")
                .navigationTitle("Application")
            }
            
            NavigationView {
                Placeholder(systemImage: "wifi")
                    .padding()
                    .previewDisplayName("Text only")
                    .navigationTitle("Application")
            }
        }
    }
}
