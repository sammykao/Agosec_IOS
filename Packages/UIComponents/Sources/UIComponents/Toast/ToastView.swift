import SwiftUI
import UIKit

public struct ToastView: View {
    public let message: String
    public let type: ToastType
    public let retryAction: (() -> Void)?

    public enum ToastType {
        case success
        case error
        case info
    }

    public init(message: String, type: ToastType = .info, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.type = type
        self.retryAction = retryAction
    }

    public var body: some View {
        let displayMessage = truncateIfNeeded(message)
        let lineLimit = type == .error ? 5 : 3

        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.system(size: 18))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(displayMessage)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .lineLimit(lineLimit)
                    .fixedSize(horizontal: false, vertical: true)

                if let retryAction = retryAction {
                    Button(action: retryAction) {
                        Text("Retry")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(6)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: min(UIScreen.main.bounds.width - 32, 500))
        .background(backgroundColor)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    private func truncateIfNeeded(_ message: String) -> String {
        // Truncate extremely long messages (over 600 characters) but keep more context
        let maxLength = 600
        if message.count > maxLength {
            let truncated = String(message.prefix(maxLength))
            // Try to truncate at a sentence boundary if possible
            if let lastPeriod = truncated.lastIndex(of: ".") {
                let sentenceEnd = truncated.index(after: lastPeriod)
                return String(truncated[..<sentenceEnd]) + "..."
            }
            // Otherwise truncate at word boundary
            if let lastSpace = truncated.lastIndex(of: " ") {
                return String(truncated[..<lastSpace]) + "..."
            }
            return truncated + "..."
        }
        return message
    }

    private var iconName: String {
        switch type {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    private var iconColor: Color {
        switch type {
        case .success:
            return .green
        case .error:
            return .red
        case .info:
            return .blue
        }
    }

    private var backgroundColor: Color {
        switch type {
        case .success:
            return Color.green.opacity(0.9)
        case .error:
            return Color.red.opacity(0.9)
        case .info:
            return Color.blue.opacity(0.9)
        }
    }
}

public class ToastManager: ObservableObject {
    @Published public var currentToast: ToastMessage?
    private var dismissTask: Task<Void, Never>?

    public init() {}

    public func show(
        _ message: String,
        type: ToastView.ToastType = .info,
        duration: TimeInterval = 3.0,
        retryAction: (() -> Void)? = nil
    ) {
        // Cancel any existing dismiss task
        dismissTask?.cancel()

        currentToast = ToastMessage(message: message, type: type, duration: duration, retryAction: retryAction)

        // Auto-dismiss after duration (unless it's an error with retry, then give more time)
        let dismissDuration = retryAction != nil ? duration + 2.0 : duration
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(dismissDuration * 1_000_000_000))
            if !Task.isCancelled {
                await MainActor.run {
                    self.hide()
                }
            }
        }
    }

    public func hide() {
        dismissTask?.cancel()
        currentToast = nil
    }
}

// Global toast manager instance
public extension ToastManager {
    static let shared = ToastManager()
}

public struct ToastMessage {
    public let message: String
    public let type: ToastView.ToastType
    public let duration: TimeInterval
    public let retryAction: (() -> Void)?

    public init(
        message: String,
        type: ToastView.ToastType,
        duration: TimeInterval = 3.0,
        retryAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.type = type
        self.duration = duration
        self.retryAction = retryAction
    }
}
