//
// Created by Nick Kibysh on 04/08/2022.
//

import Foundation

struct TimeoutError: Error {}

func asyncOperation<T>(
        timeout nanoseconds: UInt64 = 10_000_000_000,
        operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { (group: inout ThrowingTaskGroup<T, Swift.Error>) -> T in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(nanoseconds: nanoseconds)
            try Task.checkCancellation()
            throw TimeoutError()
        }

        defer {
            group.cancelAll()
        }

        return try await group.next()!
    }
}