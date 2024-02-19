//
//  ProvisionManager.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Nick Kibysh on 12/02/2024.
//

import Foundation
import NetworkExtension

open class ProvisionManager {
    private let endpoint = "https://192.0.2.1/"
    private let apSSID = "mobileappsrules"
    public init() {
    }
    
    public enum ProvisionError: Error {
        case httpError(Int)
        case badResponse
    }
    
    open func connect() async throws {
        let connectedAlready: Bool
        // If we're connected, this should return a response. True or false.
        switch await ledStatus(ledNumber: 1) {
        case .success:
            connectedAlready = true
        case .failure:
            connectedAlready = false
        }
        
        guard !connectedAlready else {
            // Nothing to do here.
            print("Provisioning Device replied to LED Status - We're already connected.")
            return
        }
        
        // Ask the user to switch to the Provisioning Device's Wi-Fi Network.
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: apSSID)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.apply(configuration) { error in
                if let nsError = error as? NSError, nsError.code == 13 {
                    continuation.resume()
                    print("already connected")
                } else if let error {
                    continuation.resume(throwing: error)
                    print(error.localizedDescription)
                } else {
                    continuation.resume()
                    print("connected")
                }
            }
        }
    }
    
    open func ledStatus(ledNumber: Int) async -> Result<Bool, Error> {
        let url = URL(string: "\(endpoint)led/\(ledNumber)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 7.0
        
        let session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        
        do {
            let response = try await session.data(for: request)
            guard let httpResponse = response.1 as? HTTPURLResponse else {
                return .failure(ProvisionError.badResponse)
            }
            
            guard httpResponse.statusCode < 400 else {
                return .failure(ProvisionError.httpError(httpResponse.statusCode))
            }
            
            guard let responseText = String(data: response.0, encoding: .utf8)?.split(separator: "\r\n").last else {
                return .failure(ProvisionError.badResponse)
            }
            
            switch responseText {
            case "0": 
                return .success(false)
            case "1": 
                return .success(true)
            default: 
                return .failure(ProvisionError.badResponse)
            }
        } catch {
            return .failure(error)
        }
    }
    
    open func setLED(ledNumber: Int, enabled: Bool) async -> Result<Void, Error> {
        let url = URL(string: "\(endpoint)led/\(ledNumber)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = "\(enabled ? 1 : 0)".data(using: .utf8)
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        do {
            let response = try await session.data(for: request)
            guard let urlResponse = (response.1 as? HTTPURLResponse) else {
                return .failure(ProvisionError.badResponse)
            }
            let error = NSError(domain: NSURLErrorDomain, code: urlResponse.statusCode)
            return error.code == 200 ? .success(()) : .failure(error)
        } catch {
            return .failure(error)
        }
    }
    
    open func getSSIDs() async throws -> [String] {
        let url = URL(string: "\(endpoint)wifi/ssid")!

        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        
        let ssidsResponse = try await session.data(from: url)

        if let resp = ssidsResponse.1 as? HTTPURLResponse, resp.statusCode >= 400 {
            throw ProvisionError.httpError(resp.statusCode)
        }
        
        let strings = String(data: ssidsResponse.0, encoding: .utf8)
        guard let ssid = strings?.split(separator: "\n").dropFirst(2) else {
            fatalError()
        }

        return Array(ssid).map { String($0) }
    }
    
    func provision(ssid: String, password: String) async throws {
        
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
