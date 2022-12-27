//
//  File.swift
//  
//
//  Created by Nick Kibysh on 01/11/2022.
//

import Foundation
import XCTest

extension DispatchQueue {
    func asyncAfter(fromNow seconds: Int, expectation: XCTestExpectation? = nil, handler: @escaping () throws -> ()) {
        defer {
            if let expectation {
                expectation.fulfill()
            }
        }
        
        self.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(seconds)) {
            do {
                try handler()
            } catch let err {
                XCTFail("Error: \(err.localizedDescription)")
            }
        }
    }
}
