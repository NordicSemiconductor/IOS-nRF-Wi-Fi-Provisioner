//
//  NFCProvisioningSessionDelegate.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 9/5/24.
//

import Foundation
import CoreNFC

// MARK: - NFCProvisioningSessionDelegate

final class NFCProvisioningSessionDelegate: NSObject, NFCNDEFReaderSessionDelegate {
    
    // MARK: Properties
    
    var message: NFCProvisioningMessage?
    
    // MARK: API
    
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
    
    /**
     Attribution: https://developer.apple.com/documentation/corenfc/building_an_nfc_tag-reader_app
     */
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        print(#function)
        if tags.count > 1 {
            restart(session, with: "More than 1 NFC Tag is detected. Please remove all tags and try again.")
            return
        }
        
        guard let tag = tags.first,
              let ndefMessage = message?.nfcndefMessage() else {
            return
        }
        
        session.connect(to: tag, completionHandler: { [weak self] (error: Error?) in
            if let error {
                self?.onError(session, errorDescription: "Unable to Connect: \(error.localizedDescription)")
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    self?.onError(session, errorDescription: "Unable to query the NFC Tag's status.")
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    self?.onError(session, errorDescription: "Tag is not NDEF compliant.")
                case .readOnly:
                    self?.onError(session, errorDescription: "NFC Tag is Read-Only.")
                case .readWrite:
                    tag.writeNDEF(ndefMessage, completionHandler: { (error: Error?) in
                        if let error {
                            self?.onError(session, errorDescription: "Error writing to NFC Tag: \(error)")
                        } else {
                            self?.onError(session, errorDescription: "Successfully Provisioned NFC Tag!")
                        }
                    })
                @unknown default:
                    self?.onError(session, errorDescription: "Unknown NFC Tag Error.")
                }
            })
        })
    }
    
    // MARK: Private
    
    private func restart(_ session: NFCNDEFReaderSession, with message: String) {
        // Restart polling in 500 milliseconds.
        let retryInterval = DispatchTimeInterval.milliseconds(500)
        session.alertMessage = message
        DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
            session.restartPolling()
        })
    }
    
    private func onError(_ session: NFCNDEFReaderSession, errorDescription: String) {
        session.alertMessage = errorDescription
        session.invalidate()
    }
}
