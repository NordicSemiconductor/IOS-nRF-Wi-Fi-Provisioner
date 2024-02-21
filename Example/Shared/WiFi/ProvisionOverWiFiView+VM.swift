//
//  ProvisionOverWiFiView+VM.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 20/02/2024.
//

import SwiftUI
import NordicWiFiProvisioner_SoftAP

extension ProvisionOverWiFiView {
    @MainActor
    class ViewModel: ObservableObject {
        enum LedStatus {
            case notDetermined, on, off, error(Error)
            
            var disabled: Bool {
                switch self {
                case .on, .off: return false
                default: return true
                }
            }
        }
        
        enum Status {
            case notConnected
            case connecting
            case connected
            case error(_ error: Error)
        }
        
        @Published private (set) var status = Status.notConnected
        private var manager = ProvisionManager()
        @Published private (set) var ssids: [ReportedSSID] = []
        @Published var selectedSSID: ReportedSSID?
        @Published var ssidPassword: String = ""
        
        @Published private (set) var led1Status = LedStatus.notDetermined
        @Published private (set) var led2Status = LedStatus.notDetermined
        
        @Published private (set) var alertError: TitleMessageError? = nil
        @Published var showAlert: Bool = false
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
        }
    }
    
    func readLedStatus() async {
        do {
            led1Status = try await manager.ledStatus(ledNumber: 1) ? .on : .off
        } catch {
            led1Status = .error(error)
            alertError = TitleMessageError(title: "Can't read LED 1 Status", error: error)
            showAlert = true
        }
        
        do {
            led2Status = try await manager.ledStatus(ledNumber: 2) ? .on : .off
        } catch {
            led2Status = .error(error)
            alertError = TitleMessageError(title: "Can't read LED 2 Status", error: error)
            showAlert = true
        }
    }
    
    func toggleLedStatus(ledNumber: Int) async {
        if ledNumber == 1 {
            led1Status = await updateLedStatus(ledNumber: ledNumber, currentStatus: led1Status)
        } else if ledNumber == 2 {
            led2Status = await updateLedStatus(ledNumber: ledNumber, currentStatus: led2Status)
        }
    }
    
    private func updateLedStatus(ledNumber: Int, currentStatus: LedStatus) async -> LedStatus {
        guard !currentStatus.disabled else { return currentStatus }
        
        var status = currentStatus
        
        do {
            if case .on = currentStatus {
                try await manager.setLED(ledNumber: ledNumber, enabled: false)
                status = .off
            } else if case .off = currentStatus {
                try await manager.setLED(ledNumber: ledNumber, enabled: true)
                status = .on
            }
        } catch {
            alertError = TitleMessageError(title: "Can't toggle LED", error: error)
            showAlert = true
        }
        
        return status
    }
    
    func getSSIDs() async {
        do {
            ssids = try await manager.getSSIDs()
        } catch {
            alertError = TitleMessageError(title: "Can't scan for wifi networks", error: error)
            showAlert = true
        }
    }
}
