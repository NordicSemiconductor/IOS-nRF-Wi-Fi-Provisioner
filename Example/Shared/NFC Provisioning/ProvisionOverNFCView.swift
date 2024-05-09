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
    private let delegate: NFCSessionDelegate
    
    // MARK: init
    
    init() {
        self.delegate = NFCSessionDelegate()
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

// MARK: - NFCSessionDelegate

final class NFCSessionDelegate: NSObject, NFCNDEFReaderSessionDelegate {
    
    var message: NFCProvisioningMessage?
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print(#function)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        print(#function)
        print(error)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print(#function)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        print(#function)
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 NFC Tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        guard let tag = tags.first,
              let ndefMessage = message?.nfcndefMessage() else {
            return
        }
        
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NFC Tag's status."
                    session.invalidate()
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "NFC Tag is Read-Only."
                    session.invalidate()
                case .readWrite:
                    tag.writeNDEF(ndefMessage, completionHandler: { (error: Error?) in
                        if let error {
                            session.alertMessage = "Error writing to NFC Tag: \(error)"
                        } else {
                            session.alertMessage = "Successfully Provisioned NFC Tag!"
                        }
                        session.invalidate()
                    })
                @unknown default:
                    session.alertMessage = "Unknown NFC Tag Error."
                    session.invalidate()
                }
            })
        })
    }
}
