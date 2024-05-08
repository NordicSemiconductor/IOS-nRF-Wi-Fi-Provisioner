//
//  NFCProvisioningMessage.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 8/5/24.
//

import Foundation
import CoreNFC

// MARK: - NFCProvisioningMessage

struct NFCProvisioningMessage {
    
    // MARK: Private Properties
    
    private let ssid: String
    private let passphrase: String
    private let authentication: NFCAuthenticationType
    private let encryption: NFCEncryptionType
    
    // MARK: Init
    
    init(ssid: String, passphrase: String, authentication: NFCAuthenticationType, encryption: NFCEncryptionType) {
        self.ssid = ssid
        self.passphrase = passphrase
        self.authentication = authentication
        self.encryption = encryption
    }
    
    // MARK: API
    
    func nfcndefMessage() -> NFCNDEFMessage {
        let type = "application/vnd.wfa.wsc".data(using: .utf8)!
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
        return NFCNDEFMessage(records: [ndefPayload])
    }
}
