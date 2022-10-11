//
//  String+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 05/10/2022.
//

import Foundation

extension String {
    func decodeBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func encodeBase64() -> Data? {
        return Data(base64Encoded: self)
    }
}
