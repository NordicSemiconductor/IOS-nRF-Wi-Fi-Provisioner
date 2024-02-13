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
    public init() {
    }
    
    @objc private var session: URLSession? = nil
    
    open func connect() async throws {
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: "mobileappsrules")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.apply(configuration) { error in
                if let error {
                    continuation.resume(throwing: error)
                    print(error.localizedDescription)
                } else {
                    continuation.resume()
                    print("connected")
                }
            }
        }
    }

    open func setLED(ledNumber: Int, enabled: Bool) async throws {
        let url = URL(string: "\(endpoint)led/\(ledNumber)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = "\(enabled ? 1 : 0)".data(using: .utf8)

        session = URLSession.shared
        
        var config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        session = URLSession(configuration: config, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
        
        if let response = try await session?.data(for: request) {
            print(response.0)
            print(response.1)
        }
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
