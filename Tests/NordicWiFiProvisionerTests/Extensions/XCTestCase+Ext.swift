//
//  File.swift
//  
//
//  Created by Nick Kibysh on 01/11/2022.
//

import Foundation
import XCTest

extension XCTestCase {
    func wait(_ seconds: Int) {
        let e = expectation(description: "exp")
        DispatchQueue.global().asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(seconds)) {
            e.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(seconds * 1000 + 10))
    }
}
