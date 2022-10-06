//
//  ContentView.swift
//  Shared
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI
import NordicStyle

struct IntroView: View {
    @State private var animationAmount = 1.0
    @State private var selection: Int? = nil
    
    @StateObject var viewModel = IntroViewModel()
    
    @Binding var show: Bool
    @Binding var dontShowAgain: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                Image(viewModel.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("The application allows provisioning of a new nRF700x device to Wi-Fi networks over Bluetooth LE.")
                        .padding()
                    VStack(alignment: .leading) {
                        Text("**Key features:**")
                            .font(.title2)
                        Text("• Provision of a new device to the desired network.")
                        Text("• Get the connection status of the provisioned device.")
                        Text("• Re-provision already provisioned devices to an alternate network.")
                    }
                    .padding()
                    VStack(alignment: .leading) {
                        Text("**Requirements:**")
                            .font(.title2)
                        Text("• [nRF700x DK](https://nordicsemi.no)")
                        Text("• Provisioning sample app flashed")
                    }
                    .padding()
                    
                    Text("Make sure the device is powered ON and in range of the phone.")
                        .padding()
                }
                
                Text("Version: \(viewModel.version)")
                    .multilineTextAlignment(.trailing)
                    .font(.caption)
                    .padding()
                
                HStack {
                    Toggle("Don't show again", isOn: $viewModel.dontShowAgain)
                }
                .padding()
                
                Button("START_PROVISIONING_BTN") {
                    show = false
                }
                .buttonStyle(NordicButtonStyle())
                .padding()
                .accessibilityIdentifier("start_provisioning_btn")
            }
            .navigationTitle("Welcome")
            .onAppear { try? viewModel.readInfo() }
            
            
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IntroView(show: .constant(true), dontShowAgain: .constant(false))
        }
    }
}
#endif
