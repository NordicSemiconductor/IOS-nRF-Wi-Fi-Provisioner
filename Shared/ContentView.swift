//
//  ContentView.swift
//  Shared
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI
import NordicStyle

struct ContentView: View {
    @State private var animationAmount = 1.0
    @State private var selection: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image(systemName: "wifi")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .foregroundColor(.nordicBlue)
                    
                    Text("INTRO_TEXT")
                    
                    Spacer()
                    
                    NavigationLink(destination: Text(""), tag: 1, selection: $selection) {
                        Button("START_PROVISIONING_BTN") {
                            selection = 1
                        }
                        .buttonStyle(NordicButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Wi-Fi")
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
