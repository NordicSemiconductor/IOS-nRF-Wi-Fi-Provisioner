//
//  NoContentView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 22/02/2024.
//

import SwiftUI

struct NoContentView<Action: View>: View {
    let title: LocalizedStringKey
    let description: String?
    let systemImage: String
    let action: () -> Action
    
    init(title: LocalizedStringKey, description: String? = nil, systemImage: String, action: @escaping () -> Action) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        VStack {
            if #available(iOS 17, *) {
                newNoContentView
            } else {
                oldNoContentView
            }
            action()
        }
        .padding()
    }
    
    @available(iOS 17.0, *)
    @ViewBuilder
    private var newNoContentView: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: description.map(Text.init)
        )
    }
    
    @ViewBuilder 
    private var oldNoContentView: some View {
        VStack {
            Label(title, systemImage: systemImage)
                .font(.largeTitle)
            if let description {
                Text(description)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    NoContentView(
        title: "No Content",
        systemImage: "hand.raised") {
            Button {
                
            } label: {
                Text("Action")
            }
        }
}

#Preview {
    NoContentView(
        title: "No Content",
        description: "Description Text",
        systemImage: "hand.raised"
    ) {
            Button {
                
            } label: {
                Text("Action")
            }
        }
}

