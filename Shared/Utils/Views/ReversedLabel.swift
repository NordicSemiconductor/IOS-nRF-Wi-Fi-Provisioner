//
//  ReversedLabel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 01/08/2022.
//

import SwiftUI

struct ReversedLabel<T: View, I: View>: View {
    var text: () -> T
    var image: () -> I

    init(text: @escaping () -> T, image: @escaping () -> I) {
        self.text = text
        self.image = image
    }

    init(text: String, image: String) where T == Text, I == Image {
        self.text = { Text(text) }
        self.image = { Image(image) }
    }

    init(text: String, systemImage: String) where T == Text, I == Image {
        self.text = { Text(text) }
        self.image = { Image(systemName: systemImage) }
    }

    var body: some View {
        HStack {
            text()
            Spacer().frame(maxWidth: 8)
            image()
        }
    }
}

#if DEBUG
struct ReversedLabel_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                ReversedLabel(text: {
                    Text("Text from closure")
                }, image: {
                    Image(systemName: "checkmark")
                })
                
                ReversedLabel(text: "Static Text", systemImage: "checkmark")
                
                ReversedLabel {
                    Text("Status")
                } image: {
                    ProgressView()
                }

            }
        }
    }
}
#endif
