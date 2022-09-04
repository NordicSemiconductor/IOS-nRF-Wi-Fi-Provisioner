//
// Created by Nick Kibysh on 01/09/2022.
//

import Foundation

struct AsyncExecutor<T> {
    private var continuation: CheckedContinuation<T, Error>!
    private var result: Swift.Result<T, Error>!

    mutating func execute() async throws -> T {
        reset()
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            if let result = self.result {
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            } else {
                self.continuation = continuation
            }
        }
    }

    mutating func complete(with value: T) {
        if let continuation = self.continuation {
            continuation.resume(returning: value)
        } else {
            self.result = .success(value)
        }
    }

    mutating func complete(with error: Error) {
        if let continuation = self.continuation {
            continuation.resume(throwing: error)
        } else {
            self.result = .failure(error)
        }
    }

    mutating func reset() {
        self.continuation = nil
        self.result = nil
    }
}

