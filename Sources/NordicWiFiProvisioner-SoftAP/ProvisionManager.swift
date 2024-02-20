//
//  ProvisionManager.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Nick Kibysh on 12/02/2024.
//

import Foundation
import NetworkExtension
import OSLog

private extension URL {
    static let endpointStr = "https://192.0.2.1/"
    
    static let ssid = URL(string: "\(endpointStr)wifi/ssid")!
    static let prov = URL(string: "\(endpointStr)wifi/prov")!
    
    static func led(_ ledNumber: Int) -> URL {
        let url = URL(string: "\(endpointStr)led/")!
        if #available(iOS 16, *) {
            return url.appending(component: "\(ledNumber)")
        } else {
            return url.appendingPathComponent("\(ledNumber)")
        }
    }
}

open class ProvisionManager {
    private let apSSID = "mobileappsrules"
    public init() {
    }
    
    public enum ProvisionError: Error {
        case badResponse
    }
    
    public struct HTTPError: Error {
        let code: Int
        let responseData: Data?
        
        init(code: Int, responseData: Data?) {
            assert(code >= 400)
            self.code = code
            self.responseData = responseData
        }
    }
    
    private let l = Logger(subsystem: "com.nordicsemi.NordicWiFiProvisioner-SoftAP", category: "SoftAP-Provisioner")
    
    open func connect() async throws {
        // Ask the user to switch to the Provisioning Device's Wi-Fi Network.
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: apSSID)
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
    
    open func ledStatus(ledNumber: Int) async throws -> Bool {
        var request = URLRequest(url: .led(ledNumber))
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 7.0
        
        let session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        
        do {
            let response = try await session.data(for: request)
            guard let httpResponse = response.1 as? HTTPURLResponse else {
                throw ProvisionError.badResponse
            }
            
            guard httpResponse.statusCode < 400 else {
                throw HTTPError(code: httpResponse.statusCode, responseData: response.0)
            }
            
            guard let responseText = String(data: response.0, encoding: .utf8)?.split(separator: "\r\n").last else {
                throw ProvisionError.badResponse
            }
            
            switch responseText {
            case "0": 
                return false
            case "1":
                return true
            default:
                throw ProvisionError.badResponse
            }
        } catch {
            throw error
        }
    }
    
    open func setLED(ledNumber: Int, enabled: Bool) async throws {
        var request = URLRequest(url: .led(ledNumber))
        request.httpMethod = "PUT"
        request.httpBody = "\(enabled ? 1 : 0)".data(using: .utf8)
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
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
    
    open func getSSIDs() async throws -> [ReportedSSID] {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        
        let ssidsResponse = try await session.data(from: .ssid)

        if let resp = ssidsResponse.1 as? HTTPURLResponse, resp.statusCode >= 400 {
            throw HTTPError(code: resp.statusCode, responseData: ssidsResponse.0)
        }
        
        let strings = String(data: ssidsResponse.0, encoding: .utf8)
        
        guard let splitContent = strings?.split(separator: "\r\n") else {
            throw ProvisionError.badResponse
        }
        
        let contentLength = splitContent.first
        guard let ssid = splitContent.last?.split(separator: "\n") else {
            throw ProvisionError.badResponse
        }

        return ssid.map { ReportedSSID(String($0)) }
    }
    
    func provision(ssid: String, password: String) async throws {
        
    }
}

public struct ReportedSSID: Identifiable, Hashable {
    public var id: String { ssid }
    
    public var ssid: String
    
    init(_ ssid: String) {
        self.ssid = ssid
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
