//
//  Counter.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 14/07/2022.
//

import Combine

struct Counter : AsyncSequence {
    typealias Element = Int
    let howHigh: Int

    struct AsyncIterator : AsyncIteratorProtocol {
        let howHigh: Int
        var current = 1
        mutating func next() async -> Int? {
            // A genuinely asychronous implementation uses the `Task`
            // API to check for cancellation here and return early.
            guard current <= howHigh else {
                return nil
            }

            let result = current
            current += 1
            return result
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(howHigh: howHigh)
    }
}
