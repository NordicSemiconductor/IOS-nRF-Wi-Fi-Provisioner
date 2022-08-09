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
    
    @Binding var show: Bool
    @Binding var dontShowAgain: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image(systemName: "wifi")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .foregroundColor(.nordicBlue)
                        .frame(maxHeight: 170)
                    
                    Text("INTRO_TEXT")
                    
                    Spacer()
                    
                    Toggle("Do not show again", isOn: $dontShowAgain)
                    Button("START_PROVISIONING_BTN") {
                        show = false
                    }
                    .buttonStyle(NordicButtonStyle())
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
        ContentView(show: .constant(true), dontShowAgain: .constant(false))
    }
}
#endif
