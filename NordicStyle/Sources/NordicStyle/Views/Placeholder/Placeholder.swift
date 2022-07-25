//
//  SwiftUIView.swift
//  
//
//  Created by Nick Kibysh on 19/07/2022.
//

import SwiftUI

public
struct Placeholder: View {
    public let text: String?
    public let image: Image
    
    public init(text: String? = nil, image: String) {
        self.text = text
        self.image = Image(image)
    }
    
    public init(text: String? = nil, systemImage: String) {
        self.text = text
        self.image = Image(systemName: systemImage)
    }
    
    public var body: some View {
        VStack {
            if #available(iOS 15.0, *) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 250, maxHeight: 300)
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
                    .frame(maxWidth: 300)
            }
            
        }
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
