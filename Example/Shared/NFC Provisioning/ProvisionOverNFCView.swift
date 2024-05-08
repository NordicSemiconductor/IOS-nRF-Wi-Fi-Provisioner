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
    
    // MARK: Properties
    
    @State private var ssid: String = ""
    @State private var password: String = ""
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
//            .disabled(ssid.isEmpty)
        }
        .navigationTitle("Provision Over NFC")
    }
    
    // MARK: Private
    
    private func writeTag() {
        delegate.ssid = ssid
        delegate.passphrase = password
        session.alertMessage = "Hold your iPhone near an NDEF tag to write the message."
        session.begin()
    }
}

enum NFCAuthenticationType: UInt8, RawRepresentable {
    case open = 0x01
    case wpaPersonal = 0x02
    case shared = 0x04
    case wpaEnterprise = 0x08
    case wpa2Enterprise = 0x10
    case wpa2Personal = 0x20
    
    var bytes: [UInt8] { [0x00, rawValue] }
}

enum NFCEncryptionType: UInt8, RawRepresentable {
    case none = 0x01
    case wep = 0x02
    case tkip = 0x04
    case aes = 0x08
    case aesTkipMixed = 0x0c
    
    var bytes: [UInt8] { [0x00, rawValue] }
}

// MARK: - NFCSessionDelegate

final class NFCSessionDelegate: NSObject, NFCNDEFReaderSessionDelegate {
    
    var ssid: String = ""
    var passphrase: String = ""
    
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
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        let type = "application/vnd.wfa.wsc".data(using: .utf8)!

        let authentication = NFCAuthenticationType.wpa2Personal
        let encryption = NFCEncryptionType.aes

        let ssidBytes: [UInt8] = Array(ssid.utf8)
        let passphraseBytes: [UInt8] = Array(passphrase.utf8)

        let ssidLength = UInt8(ssidBytes.count)
        let passphraseLength = UInt8(passphraseBytes.count)

        let networkIndex: [UInt8] = [0x10, 0x26, 0x00, 0x01, 0x01]
        let ssid: [UInt8] = [0x10, 0x45, 0x00, ssidLength] + ssidBytes
        let authenticationType: [UInt8] = [0x10, 0x03, 0x00, 0x02] + authentication.bytes
        let encryptionType: [UInt8] = [0x10, 0x0F, 0x00, 0x02] + encryption.bytes
        let passphraseKey: [UInt8] = [0x10, 0x27, 0x00, passphraseLength] + passphraseBytes
        let macAddress: [UInt8] = [0x10, 0x20, 0x00, 0x06, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]

        let credential = networkIndex + ssid + authenticationType + encryptionType + passphraseKey + macAddress
        let credentialLength = UInt8(credential.count)

        let bytes = [0x10, 0x0E, 0x00, credentialLength] + credential
        let payload = Data(bytes: bytes, count: bytes.count)

        let ndefPayload = NFCNDEFPayload(format: .media, type: type, identifier: Data(), payload: payload)
        let message = NFCNDEFMessage(records: [ndefPayload])
        
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
                    tag.writeNDEF(message, completionHandler: { (error: Error?) in
                        if nil != error {
                            session.alertMessage = "Write NDEF message fail: \(error!)"
                        } else {
                            session.alertMessage = "Write NDEF message successful."
                        }
                        session.invalidate()
                    })
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    session.invalidate()
                }
            })
        })
    }
}
