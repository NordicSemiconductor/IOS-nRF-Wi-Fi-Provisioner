/*
* Copyright (c) 2024, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import Network
import NetworkExtension
import OSLog
import SwiftProtobuf

// MARK: ProvisionManager

public class ProvisionManager {
    
    // MARK: Properties
    
    private let sessionDelegate: NSURLSessionPinningDelegate
    private lazy var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15 // seconds
        return configuration
    }()
    private lazy var urlSession = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)
    
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
        
        do {
            let provisionResponse = try await urlSession.data(for: request)
            if let response = provisionResponse.1 as? HTTPURLResponse, response.statusCode >= 400 {
                print("Provisioning Response")
                print(provisionResponse)
                throw HTTPError(code: response.statusCode, responseData: provisionResponse.0)
            }
        } catch {
            print("Caught Error")
            print(error)
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
