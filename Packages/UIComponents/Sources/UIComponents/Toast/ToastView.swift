import SwiftUI

public struct ToastView: View {
    public let message: String
    public let type: ToastType
    
    public enum ToastType {
        case success
        case error
        case info
    }
    
    public init(message: String, type: ToastType = .info) {
        self.message = message
        self.type = type
    }
    
    public var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(8)
        .shadow(radius: 4)
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
    
    public init() {}
    
    public func show(_ message: String, type: ToastView.ToastType = .info, duration: TimeInterval = 3.0) {
        currentToast = ToastMessage(message: message, type: type, duration: duration)
    }
    
    public func hide() {
        currentToast = nil
    }
}

public struct ToastMessage {
    public let message: String
    public let type: ToastView.ToastType
    public let duration: TimeInterval
    
    public init(message: String, type: ToastView.ToastType, duration: TimeInterval) {
        self.message = message
        self.type = type
        self.duration = duration
    }
}