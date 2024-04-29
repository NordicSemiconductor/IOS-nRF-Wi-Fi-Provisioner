//
//  Bundle.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 17/4/24.
//

import Foundation

// MARK: Bundle

extension Bundle {
    func certificateNamed(_ name: String) -> SecCertificate? {
        guard let certURL = self.url(forResource: name, withExtension: "cer"),
              let certData = try? Data(contentsOf: certURL),
              let cert = SecCertificateCreateWithData(nil, certData as NSData) else {
            return nil
        }
        return cert
    }
}
