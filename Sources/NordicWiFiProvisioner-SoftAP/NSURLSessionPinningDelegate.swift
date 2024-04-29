//
//  NSURLSessionPinningDelegate.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 16/2/24.
//

import Foundation
import NetworkExtension
import OSLog

// MARK: - NSURLSessionPinningDelegate

final class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    // MARK: Private Properties
    
    private let certificateURL: URL
    
    private lazy var logger = Logger(subsystem: "com.nordicsemi.NordicWiFiProvisioner-SoftAP",
                                     category: "NSURLSessionPinningDelegate")
    
    // MARK: Init
    
    init(certificateURL: URL) {
        self.certificateURL = certificateURL
        super.init()
    }
    
    // MARK: URLSessionDelegate
    
    func urlSession(_ session: URLSession,
                      didReceive challenge: URLAuthenticationChallenge,
                      completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                Task {
                    let result = await shouldAllowHTTPSConnection(trust: serverTrust)
                    if result {
                        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
                    } else {
                        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                    }
                }
            }
        }
    }

    func shouldAllowHTTPSConnection(chain: [SecCertificate]) async throws -> Bool {
        guard let certData = try? Data(contentsOf: certificateURL),
              let anchor = SecCertificateCreateWithData(nil, certData as NSData) else {
            fatalError()
        }
        
        let policy = SecPolicyCreateBasicX509()
        let trust = try secCall { SecTrustCreateWithCertificates(chain as NSArray, policy, $0) }
        let err = SecTrustSetAnchorCertificates(trust, [anchor] as NSArray)
        guard err == errSecSuccess else {
            logger.error("SecTrustSetAnchorCertificates Error: \(err)")
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
            logger.error("shouldAllowHTTPSConnection Error: \(error.localizedDescription)")
            return false
        }
    }

    func secCall<Result>(_ body: (_ resultPtr: UnsafeMutablePointer<Result?>) -> OSStatus) throws -> Result {
        var result: Result? = nil
        let err = body(&result)

        guard err == errSecSuccess else {
            logger.error("secCall Error: \(err)")
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
        return result!
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error else { return }
        logger.debug("\(#function)")
        logger.error("Error: \(error.localizedDescription)")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        logger.debug("\(#function)")
        logger.debug("\(session)")
    }
}
