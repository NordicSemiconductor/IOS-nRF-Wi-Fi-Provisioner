//
//  File.swift
//  
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
        do {
            // If we're connected, this should return a response. True or false.
            _ = try await ledStatus(ledNumber: 1)
            connectedAlready = true
        } catch {
            // If it throws, the Device Firmware did not respond / we're not connected.
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
    
    open func ledStatus(ledNumber: Int) async throws -> Bool {
        let url = URL(string: "\(endpoint)led/\(ledNumber)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 7.0
        
        let session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        
        let response = try await session.data(for: request)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw ProvisionError.badResponse
        }
        
        guard httpResponse.statusCode < 400 else {
            throw ProvisionError.httpError(httpResponse.statusCode)
        }
        
        guard let responseText = String(data: response.0, encoding: .utf8)?.split(separator: "\r\n").last else {
            throw ProvisionError.badResponse
        }
        
        switch responseText {
        case "0": return false
        case "1": return true
        default: throw ProvisionError.badResponse
        }
        
    }
    
    open func setLED(ledNumber: Int, enabled: Bool) async throws {
        let url = URL(string: "\(endpoint)led/\(ledNumber)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = "\(enabled ? 1 : 0)".data(using: .utf8)
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        
        let response = try await session.data(for: request)
        
        print(response.0)
        print(response.1)
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

class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    static let shared = NSURLSessionPinningDelegate()
    
    override init() {
        super.init()
    }
    
    func urlSession(_ session: URLSession,
                      didReceive challenge: URLAuthenticationChallenge,
                      completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {

        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                Task {
                    let result = await shouldAllowHTTPSConnection(trust: serverTrust)
                    if result == true {
                        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
                    } else {
                        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                    }
                }
            }
        }
    }

    func shouldAllowHTTPSConnection(chain: [SecCertificate]) async throws -> Bool {
        
        let b = Bundle(for: NSURLSessionPinningDelegate.self)
        guard let res = b.url(forResource: "Res", withExtension: "bundle") else {
            fatalError()
        }
        guard let resBundle = Bundle(url: res) else {
            fatalError()
        }
        let anchor = resBundle.certificateNamed("certificate")!
        
        let policy = SecPolicyCreateBasicX509()
        let trust = try secCall { SecTrustCreateWithCertificates(chain as NSArray, policy, $0) }
        let err = SecTrustSetAnchorCertificates(trust, [anchor] as NSArray)
        guard err == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }

        var secresult: CFError? = nil
        let status = SecTrustEvaluateWithError(trust, &secresult)
        return status
    }

    func shouldAllowHTTPSConnection(trust: SecTrust) async -> Bool {
        guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate] else { return false }
        do {
            return try await shouldAllowHTTPSConnection(chain: chain)
        } catch {
            return false
        }
    }

    func secCall<Result>(_ body: (_ resultPtr: UnsafeMutablePointer<Result?>) -> OSStatus  ) throws -> Result {
        var result: Result? = nil
        let err = body(&result)

        guard err == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
        return result!
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print(#function)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print(#function)
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
