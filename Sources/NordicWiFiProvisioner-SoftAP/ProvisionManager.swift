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

private extension URL {
    static let endpointStr = "https://192.0.2.1"
    
    static let ssid = URL(string: "\(endpointStr)/prov/networks")!
    static let prov = URL(string: "\(endpointStr)/prov/configure")!
}

open class ProvisionManager {
    private let apSSID = "mobileappsrules"
    public init() {
    }
    
    public enum ProvisionError: Error {
        case badResponse
        case cancelled
    }
    
    public struct HTTPError: Error, LocalizedError {
        let code: Int
        let responseData: Data?
        
        init(code: Int, responseData: Data?) {
            assert(code >= 400)
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
    
    private var sessionConfig: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return config
    }
    
    private let l = Logger(subsystem: "com.nordicsemi.NordicWiFiProvisioner-SoftAP", category: "SoftAP-Provisioner")
    
    open func connect() async throws {
        // Ask the user to switch to the Provisioning Device's Wi-Fi Network.
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: apSSID)
        try await switchWiFiEndpoint(using: manager, with: configuration)
        
//        let parameters = NWParameters()
//        parameters.allowLocalEndpointReuse = true
//        parameters.acceptLocalOnly = true
//        parameters.allowFastOpen = true
//        
//        let browser = NWBrowser(for: .bonjour(type: "_http._tcp.", domain: "local"), using: parameters)
//        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
//            browser.stateUpdateHandler = { newState in
//                switch newState {
//                case .setup:
//                    print("Setting up connection")
//                case .ready:
//                    print("Ready?")
//                case .failed(let error):
//                    print(error.localizedDescription)
//                    continuation.resume(throwing: error)
//                case .cancelled:
//                    print("Stopped / Cancelled")
//                case .waiting(let nwError):
//                    print("Waiting for \(nwError.localizedDescription)?")
//                default:
//                    break
//                }
//            }
//            
//            browser.browseResultsChangedHandler = { results, changes in
//                guard let endpoint = results.first?.endpoint else {
//                    continuation.resume(throwing: ProvisionError.badResponse)
//                    return
//                }
//                print(endpoint)
//                continuation.resume()
//            }
//            browser.start(queue: .main)
//        }
//        browser.cancel()
    }
    
    private func switchWiFiEndpoint(using manager: NEHotspotConfigurationManager,
                                    with configuration: NEHotspotConfiguration) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.apply(configuration) { error in
                if let nsError = error as? NSError, nsError.code == 13 {
                    continuation.resume()
                    self.l.info("Already Connected")
                } else if let error {
                    continuation.resume(throwing: error)
                    self.l.error("\(error.localizedDescription)")
                } else {
                    continuation.resume()
                    self.l.info("Connected")
                }
            }
        }
    }
    
    open func getSSIDs() async throws -> [APWiFiScan] {
        let session = URLSession(configuration: .default, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        
        let ssidsResponse = try await session.data(from: .ssid)
        if let resp = ssidsResponse.1 as? HTTPURLResponse, resp.statusCode >= 400 {
            throw HTTPError(code: resp.statusCode, responseData: ssidsResponse.0)
        }
        
        guard let result = try? ScanResults(serializedData: ssidsResponse.0) else {
            throw ProvisionError.badResponse
        }
        return result.results.map { APWiFiScan(scanResult: $0) }
    }
    
    open func provision(ssid: String, password: String?) async throws {
        var request = URLRequest(url: .prov)
        request.httpMethod = "PUT"
        request.addValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let bodyString = {
            if let password {
                "\(ssid) \(password)"
            } else {
                "\(ssid)"
            }
        }()
        
        request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)
        
        let session = URLSession(configuration: .default, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        do {
            let response = try await session.data(for: request)
            guard let urlResponse = (response.1 as? HTTPURLResponse) else {
                throw ProvisionError.badResponse
            }
            
            guard urlResponse.statusCode < 400 else {
                throw HTTPError(code: urlResponse.statusCode, responseData: response.0)
            }
        } catch {
            throw error
        }
    }
}

extension Bundle {
    func certificateNamed(_ name: String) -> SecCertificate? {
        guard
            let certURL = self.url(forResource: name, withExtension: "cer"),
            let certData = try? Data(contentsOf: certURL),
            let cert = SecCertificateCreateWithData(nil, certData as NSData)
        else {
            return nil
        }
        return cert
    }
}
