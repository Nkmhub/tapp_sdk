import Foundation

extension Task where Success == Never, Failure == Never {
    private static let oneSecondInNanoseconds: UInt64 = 1_000_000_000
    private static let oneMillisecondInNanoseconds: UInt64 = 1_000_000

    static func sleep(seconds: UInt64) async throws {
        if #available(iOS 16, *) {
            try await sleep(for: .seconds(seconds))
        } else {
            try await sleep(nanoseconds: oneSecondInNanoseconds * seconds)
        }
    }

    static func sleep(milliseconds: UInt64) async throws {
        if #available(iOS 16, *) {
            try await sleep(for: .milliseconds(milliseconds))
        } else {
            try await sleep(nanoseconds: oneMillisecondInNanoseconds * milliseconds)
        }
    }
}
