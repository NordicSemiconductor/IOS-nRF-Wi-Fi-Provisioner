//
//  ProvisionOverNFCView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 8/5/24.
//

import SwiftUI
import CoreNFC
import iOS_Common_Libraries

// MARK: - ProvisionOverNFCView

struct ProvisionOverNFCView: View {
    
    // MARK: Properties
    
    @State private var ssid: String = ""
    @State private var password: String = ""
    @State private var authentication: NFCAuthenticationType = .wpa2Personal
    @State private var encryption: NFCEncryptionType = .aes
    private var session: NFCNDEFReaderSession
    private let delegate: NFCProvisioningSessionDelegate
    
    // MARK: init
    
    init() {
        self.delegate = NFCProvisioningSessionDelegate()
        self.session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: false)
    }
    
    // MARK: View
    
    var body: some View {
        List {
            Section("Provisioning Configuration") {
                HStack {
                    Label("SSID", systemImage: "wifi.circle")
                        .foregroundStyle(Color.textFieldColor)
                    
                    TextField("Access Point Name", text: $ssid)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Password", systemImage: "key.horizontal")
                        .foregroundStyle(Color.textFieldColor)
                    
                    Spacer()
                    
                    SecureField("Type Here", text: $password)
                        .multilineTextAlignment(.trailing)
                }
                
                InlinePicker(title: "Authentication", systemImage: "shield.checkered",
                             selectedValue: $authentication)
                
                InlinePicker(title: "Encryption", systemImage: "lock",
                             selectedValue: $encryption)
            }
            
            Label("""
            Successful provisioning via the NFC Tag, does not guarantee correct provisioning, since there is no means to verify the device has connected and joined the provisioned network.
            """, systemImage: "exclamationmark.triangle")
                .foregroundStyle(Color.nordicFall)
            
            Button("Provision NFC Tag") {
                writeTag()
            }
            .frame(maxWidth: .infinity)
            .disabled(ssid.isEmpty)
        }
        .navigationTitle("Provision Over NFC")
    }
    
    // MARK: Private
    
    private func writeTag() {
        delegate.message = NFCProvisioningMessage(ssid: ssid, passphrase: password, authentication: .wpa2Personal, encryption: .aes)
        session.alertMessage = "Hold your iPhone near the device's NFC Tag."
        session.begin()
    }
}
