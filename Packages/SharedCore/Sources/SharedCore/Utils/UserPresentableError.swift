import Foundation

public protocol UserPresentableError: Error {
    var userMessage: String { get }
    var isRetryable: Bool { get }
}

public extension UserPresentableError {
    var isRetryable: Bool { false }
}
