//
//  ProvisionOverWiFiView+VM.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 20/02/2024.
//

import SwiftUI
import NordicWiFiProvisioner_SoftAP
import OSLog

extension ProvisionOverWiFiView {
    @MainActor
    class ViewModel: ObservableObject {
        enum Status {
            case notConnected
            case connecting
            case connected
            case provisioned
            case error(_ error: Error)
        }
        
        @Published private (set) var status = Status.notConnected
        private var manager = ProvisionManager()
        @Published private (set) var scans: [APWiFiScan] = []
        @Published var selectedScan: APWiFiScan?
        @Published var ssidPassword: String = ""
        
        @Published private (set) var alertError: TitleMessageError? = nil
        @Published var showAlert: Bool = false
        
        private let nl = OSLog.networking
    }
}

extension ProvisionOverWiFiView.ViewModel {
    func connect() async {
        do {
            status = .connecting
            try await manager.connect()
            status = .connected
        } catch {
            status = .error(error)
            
            nl.error("Connection Error: \(error.localizedDescription)")
        }
    }
    
    func getScans() async {
        do {
            scans = try await manager.getScans()
        } catch {
            alertError = TitleMessageError(title: "Can't scan for wifi networks", error: error)
            showAlert = true
            
            nl.error("SSID: \(error.localizedDescription)")
        }
    }
    
    func provision() async {
        do {
            guard let ssid = selectedScan?.ssid else {
                throw TitleMessageError(message: "SSID is not selected")
            }
            
            let password = ssidPassword.isEmpty ? nil : ssidPassword
            try await manager.provision(ssid: ssid, password: password)
            
            status = .provisioned
        } catch {
            alertError = TitleMessageError(title: "Can't provision AP", error: error)
            showAlert = true
            
            nl.error("Provision: \(error.localizedDescription)")
        }
    }
}
