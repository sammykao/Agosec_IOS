import SwiftUI

public struct ActionButton: View {
    public let title: String
    public let action: () -> Void
    public let style: ButtonStyle
    public let isLoading: Bool
    
    public enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    public init(
        title: String,
        action: @escaping () -> Void,
        style: ButtonStyle = .primary,
        isLoading: Bool = false
    ) {
        self.title = title
        self.action = action
        self.style = style
        self.isLoading = isLoading
    }
    
    public var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
        }
        .disabled(isLoading)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .blue
        case .secondary:
            return .clear
        case .destructive:
            return .red
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return .blue
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .secondary:
            return .blue
        default:
            return .clear
        }
    }
}