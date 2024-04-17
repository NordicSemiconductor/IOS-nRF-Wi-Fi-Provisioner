//
//  ProvisionOverWiFiView+VM.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 20/02/2024.
//

import SwiftUI
import NordicWiFiProvisioner_SoftAP
import OSLog

// MARK: - ProvisionOverWiFiView.ViewModel

extension ProvisionOverWiFiView {
    
    @MainActor
    class ViewModel: ObservableObject {
        enum Status {
            case notConnected
            case connecting
            case connected(ipAddress: String)
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
        
        private let log = Logger(subsystem: Bundle.main.bundleIdentifier!, 
                                 category: "ProvisionOverWiFiView+ViewModel")
    }
}

// MARK: - ViewModel API

extension ProvisionOverWiFiView.ViewModel {
    
    func connect() async {
        do {
            status = .connecting
            let address = try await manager.connect()
            status = .connected(ipAddress: address)
        } catch {
            status = .error(error)
            log.error("Connection Error: \(error.localizedDescription)")
        }
    }
    
    func getScans() async {
        do {
            guard case .connected(let ipAddress) = status else {
                throw TitleMessageError(message: "Device Not Connected")
            }
            scans = try await manager.getScans(ipAddress: ipAddress)
        } catch {
            alertError = TitleMessageError(title: "Scanning Error", error: error)
            showAlert = true
            log.error("SSID: \(error.localizedDescription)")
        }
    }
    
    func provision() async {
        do {
            guard case .connected(let ipAddress) = status else {
                throw TitleMessageError(message: "Device Not Connected")
            }
            
            guard let ssid = selectedScan?.ssid else {
                throw TitleMessageError(message: "SSID is not selected")
            }
            
            let password = ssidPassword.isEmpty ? nil : ssidPassword
            try await manager.provision(ipAddress: ipAddress, ssid: ssid, password: password)
            status = .provisioned
        } catch {
            alertError = TitleMessageError(title: "Provisioning Error", error: error)
            showAlert = true
            log.error("Provision: \(error.localizedDescription)")
        }
    }
}
