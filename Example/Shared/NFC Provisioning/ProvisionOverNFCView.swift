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
    @FocusState private var focusedField: Field?
    private var session: NFCNDEFReaderSession
    private let delegate: NFCProvisioningSessionDelegate
    
    // MARK: Field
    
    private enum Field: Int, Hashable {
       case ssid
       case password
    }
    
    // MARK: Init
    
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
                        .foregroundColor(.primary)
                    
                    TextField("Access Point Name", text: $ssid)
                        .focused($focusedField, equals: .ssid)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }
                }
                
                HStack {
                    Label("Password", systemImage: "key.horizontal")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    SecureField("Type here", text: $password)
                        .focused($focusedField, equals: .password)
                        .multilineTextAlignment(.trailing)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                        }
                }
                
                InlinePicker(title: "Authentication", systemImage: "shield.checkered",
                             selectedValue: $authentication)
                
                InlinePicker(title: "Encryption", systemImage: "lock",
                             selectedValue: $encryption)
            }
            
            Label("""
            Successful provisioning via the NFC Tag, does not guarantee correct provisioning, since there is no means to verify the device has connected and joined the provisioned network.
            """, systemImage: "exclamationmark.triangle")
            .labeledContentStyle(.accented)
            
            Button("Provision NFC Tag") {
                writeTag()
            }
            .frame(maxWidth: .infinity)
            .disabled(ssid.isEmpty)
        }
        .navigationTitle("Provision over NFC")
    }
    
    // TODO:
    // 1. Disable Verification by Default
    // 2. Provide more information to the SSID in Provision over Wi-Fi
    // 3. Show 'Provisioning might've been succesful' in Pipeline View if only Verification failed.
    // 4. Update test Assignment documentation
    
    // MARK: Private
    
    private func writeTag() {
        delegate.message = NFCProvisioningMessage(ssid: ssid, passphrase: password, authentication: .wpa2Personal, encryption: .aes)
        session.alertMessage = "Hold your iPhone near the device's NFC Tag."
        session.begin()
    }
}
