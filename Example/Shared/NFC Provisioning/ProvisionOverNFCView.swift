//
//  ProvisionOverNFCView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 8/5/24.
//

import SwiftUI
import CoreNFC

// MARK: - ProvisionOverNFCView

struct ProvisionOverNFCView: View {
    
    @State private var ssid: String = ""
    @State private var password: String = ""
    private var session: NFCNDEFReaderSession?
    
    var body: some View {
        List {
            Section("Provisioning Configuration") {
                HStack {
                    Label("SSID", systemImage: "wifi.circle")
                    
                    TextField("Access Point Name", text: $ssid)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Password", systemImage: "key.horizontal")
                    
                    Spacer()
                    
                    SecureField("Type Here", text: $password)
                        .multilineTextAlignment(.trailing)
                }
            }
            
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
        let delegate = NFCSessionDelegate()
        let session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "Hold your iPhone near an NDEF tag to write the message."
        session.begin()
    }
}

final class NFCSessionDelegate: NSObject, NFCNDEFReaderSessionDelegate {
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and write an NDEF message to it.
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NDEF status of tag."
                    session.invalidate()
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "Tag is read only."
                    session.invalidate()
                case .readWrite:
//                    tag.writeNDEF(self.message, completionHandler: { (error: Error?) in
//                        if nil != error {
//                            session.alertMessage = "Write NDEF message fail: \(error!)"
//                        } else {
//                            session.alertMessage = "Write NDEF message successful."
//                        }
//                        session.invalidate()
//                    })
                    break
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    session.invalidate()
                }
            })
        })
    }
}
