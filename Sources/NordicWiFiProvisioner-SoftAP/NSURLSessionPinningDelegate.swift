//
//  NSURLSessionPinningDelegate.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 16/2/24.
//

import Foundation
import NetworkExtension
import OSLog

class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    static let shared = NSURLSessionPinningDelegate()
    
    override init() {
        super.init()
    }
    
    private let l = Logger(subsystem: "com.nordicsemi.NordicWiFiProvisioner-SoftAP", category: "NSURLSessionPinningDelegate")
    
    func urlSession(_ session: URLSession,
                      didReceive challenge: URLAuthenticationChallenge,
                      completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
//        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
//            if let serverTrust = challenge.protectionSpace.serverTrust {
//                Task {
//                    let result = await shouldAllowHTTPSConnection(trust: serverTrust)
//                    if result == true {
//                        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
//                    } else {
//                        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
//                    }
//                }
//            }
//        }
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
            l.error("SecTrustSetAnchorCertificates Error: \(err)")
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
            l.error("shouldAllowHTTPSConnection Error: \(error.localizedDescription)")
            return false
        }
    }

    func secCall<Result>(_ body: (_ resultPtr: UnsafeMutablePointer<Result?>) -> OSStatus  ) throws -> Result {
        var result: Result? = nil
        let err = body(&result)

        guard err == errSecSuccess else {
            l.error("secCall Error: \(err)")
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
        return result!
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error else { return }
        print(#function)
        print("Error: \(error.localizedDescription)")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print(#function)
        print(session)
    }
}
