import SwiftUI

/// A modern, consistent template for onboarding steps
public struct OnboardingStepTemplate<Content: View, BottomContent: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let content: Content
    let bottomContent: BottomContent
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    
    public init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottomContent: () -> BottomContent
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.bottomContent = bottomContent()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top spacing
                Spacer()
                    .frame(height: geometry.size.height * 0.08)
                
                // Icon with animated glow
                ZStack {
                    // Glow background
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                    
                    // Icon container
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        iconColor.opacity(0.2),
                                        iconColor.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: icon)
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [iconColor, iconColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .padding(.bottom, 32)
                
                // Title
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Subtitle
                Text(subtitle)
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .padding(.top, 12)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Custom content
                content
                    .padding(.top, 32)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                Spacer()
                
                // Bottom content (buttons)
                bottomContent
                    .padding(.horizontal, 28)
                    .padding(.bottom, 100)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }
            }
        }
    }
}

// MARK: - Modern Instruction Card

public struct ModernInstructionCard: View {
    let steps: [InstructionItem]
    
    public init(steps: [InstructionItem]) {
        self.steps = steps
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 16) {
                    // Step number with gradient
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 15, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    Text(step.text)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Spacer()
                }
                .padding(.vertical, 14)
                
                if index < steps.count - 1 {
                    Divider()
                        .padding(.leading, 48)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }
}

public struct InstructionItem: Identifiable {
    public let id = UUID()
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
}

// MARK: - Modern Feature Row

public struct ModernFeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    public init(icon: String = "checkmark.circle.fill", text: String, color: Color = .green) {
        self.icon = icon
        self.text = text
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            
            Spacer()
        }
    }
}

// MARK: - Modern Action Button

public struct ModernActionButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    public enum ButtonStyle {
        case primary
        case secondary
    }
    
    public init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundColor(style == .primary ? .white : Color.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if style == .primary {
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.blue.opacity(0.1)
                    }
                }
            )
            .cornerRadius(16)
            .shadow(
                color: style == .primary ? Color.blue.opacity(0.3) : Color.clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
