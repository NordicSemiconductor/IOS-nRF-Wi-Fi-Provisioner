//
//  ProvisionManager.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Nick Kibysh on 12/02/2024.
//

import Foundation
import Network
import NetworkExtension
import OSLog
import SwiftProtobuf

// MARK: ProvisionManager

public class ProvisionManager {
    
    // MARK: Properties
    
    private let sessionDelegate: NSURLSessionPinningDelegate
    private lazy var urlSession = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
    
    public var delegate: Delegate?
    
    // MARK: Init
    
    public init(certificateURL: URL) {
        self.sessionDelegate = NSURLSessionPinningDelegate(certificateURL: certificateURL)
    }
    
    public func getScans(ipAddress: String) async throws -> [APWiFiScan] {
        let ssidsResponse = try await urlSession.data(from: .ssid(ipAddress: ipAddress))
        if let response = ssidsResponse.1 as? HTTPURLResponse, response.statusCode >= 400 {
            throw HTTPError(code: response.statusCode, responseData: ssidsResponse.0)
        }
        
        guard let result = try? ScanResults(serializedData: ssidsResponse.0) else {
            throw ProvisionError.badResponse
        }
        
        return result.results.compactMap { try? APWiFiScan(scanRecord: $0) }
    }
    
    public func provision(ipAddress: String, to accessPoint: APWiFiScan, with password: String?) async throws {
        log(#function, level: .debug)
        
        var request = URLRequest(url: .prov(ipAddress: ipAddress))
        request.httpMethod = "POST"
        request.addValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        
        var provisioningConfiguration = WifiConfig()
        provisioningConfiguration.wifi = accessPoint.info()
        provisioningConfiguration.passphrase = (password ?? "").data(using: .utf8) ?? Data()
        request.httpBody = try! provisioningConfiguration.serializedData()
        
        let provisionResponse = try await urlSession.data(for: request)
        if let response = provisionResponse.1 as? HTTPURLResponse, response.statusCode >= 400 {
            throw HTTPError(code: response.statusCode, responseData: provisionResponse.0)
        }
    }
    
    // MARK: Private
    
    private func log(_ line: String, level: OSLogType) {
        delegate?.log(line, level: level)
    }
}

// MARK: - ProvisionManager.Delegate

public extension ProvisionManager {
    
    protocol Delegate {
        func log(_ line: String, level: OSLogType)
    }
}

// MARK: - ProvisionManager.ProvisionError

extension ProvisionManager {
    
    public enum ProvisionError: Error {
        case badResponse
        case cancelled
    }
}
 
// MARK: - ProvisionManager.HTTPError

extension ProvisionManager {
    
    public struct HTTPError: Error, LocalizedError {
        let code: Int
        let responseData: Data?
        
        init(code: Int, responseData: Data?) {
            self.code = code
            self.responseData = responseData
        }
        
        public var errorDescription: String? {
            if let responseData, let message = String(data: responseData, encoding: .utf8), !message.isEmpty {
                return "\(code): \(message)"
            } else {
                return "\(code)"
            }
        }
    }
}

// MARK: URL

private extension URL {
    static func ssid(ipAddress: String) -> URL {
        URL(string: "https://\(ipAddress)/prov/networks")!
    }
    
    static func prov(ipAddress: String) -> URL {
        URL(string: "https://\(ipAddress)/prov/configure")!
    }
}
