import Foundation
import SharedCore

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
}

enum ChatError: Error, UserPresentableError {
    case noAPIAccess
    case networkError

    var userMessage: String {
        switch self {
        case .noAPIAccess:
            return "Chat API access is not available. Please ensure you're signed in and have an active subscription," +
                " then try again. You can check your subscription status in the main app."
        case .networkError:
            return "Network error occurred while sending your message. Please check your internet connection" +
                " and try again."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .noAPIAccess:
            return false
        case .networkError:
            return true
        }
    }
}
