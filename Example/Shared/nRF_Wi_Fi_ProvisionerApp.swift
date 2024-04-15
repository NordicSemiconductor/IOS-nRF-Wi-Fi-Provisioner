//
//  nRF_Wi_Fi_ProvisionerApp.swift
//  Shared
//
//  Created by Nick Kibysh on 09/06/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE
import NordicWiFiProvisioner_SoftAP
import Network

@main
struct nRF_Wi_Fi_ProvisionerApp: App {
    
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var vmFactory = DeviceViewModelFactory()
    
    init() {
        MockManager.emulateDevices()
        
//        var netServiceBrowser = NetServiceBrowser()
        
        let parameters = NWParameters()
//        parameters.allowLocalEndpointReuse = true
//        parameters.acceptLocalOnly = true
//        parameters.allowFastOpen = true
        
//        let browser = NWBrowser(for: .bonjour(type: "_spotify-connect._tcp.", domain: "local"), using: parameters)
//        let browser = NWBrowser(for: .bonjour(type: "_http._tcp.", domain: "local"), using: parameters)
//        browser.stateUpdateHandler = { newState in
//            switch newState {
//            case .setup:
//                print("Setting up connection")
//            case .ready:
//                print("Ready?")
//            case .failed(let error):
//                print(error.localizedDescription)
//            case .cancelled:
//                print("Stopped / Cancelled")
//            case .waiting(let nwError):
//                print("Waiting for \(nwError.localizedDescription)?")
//            default:
//                break
//            }
//        }
//        
//        browser.browseResultsChangedHandler = { results, changes in
////            guard let endpoint = results.first?.endpoint else {
////                return
////            }
////            print(endpoint)
//            
//            for result in results {
//                print(result.endpoint)
//            }
//        }
//        browser.start(queue: .main)
////            browser.cancel()
//        
////        08:3a:88:d5:22:e0._spotify-connect._tcplocal.
////        SpZc-D66DD9._spotify-connect._tcplocal.
////        wifiprov._http._tcplocal.
//        let service = NetService(domain: "local", type: "_spotify-connect._tcp.", name: "SpZc-D66DD9")
        
//        let service = NetService(domain: "local", type: "_http._tcp.", name: "wifiprov")
//        BonjourResolver.resolve(service: service) { result in
//            switch result {
//            case .success(let hostName):
//                print("did resolve, host: \(hostName)")
//            case .failure(let error):
//                print("did not resolve, error: \(error)")
//            }
//        }
//        RunLoop.current.run(until: Date(timeIntervalSinceNow: 5))
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SelectorView()
                    .environmentObject(vmFactory)
                    .navigationTitle("nRF Wi-Fi Provisioner")
            }
            .sheet(isPresented: $viewModel.showStartInfo) {
                IntroView(show: $viewModel.showStartInfo,
                          dontShowAgain: $viewModel.dontShowAgain)
            }
        }
    }
}
