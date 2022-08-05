//
// Created by Nick Kibysh on 04/08/2022.
//

import Foundation
import os

struct TimeoutError: Error {}

public func withTimeout<R>(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> R
) async throws -> R {
    return try await withThrowingTaskGroup(of: R.self) { group in
        let deadline = Date(timeIntervalSinceNow: seconds)

        // Start actual work.
        group.addTask {
            return try await operation()
        }
        // Start timeout child task.
        group.addTask {
            let interval = deadline.timeIntervalSinceNow
            if interval > 0 {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
            try Task.checkCancellation()
            Logger(
                    subsystem: Bundle(for: Provisioner.self).bundleIdentifier ?? "",
                    category: "provisioner-global"
                ).error("Timeout error")
            throw TimeoutError()
        }
        // First finished child task wins, cancel the other task.
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}