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
            let isSmallScreen = geometry.size.width < 380
            let iconContainerSize = min(geometry.size.width * 0.26, 100)
            let glowSize = iconContainerSize * 1.2
            let iconFontSize = min(geometry.size.width * 0.11, 44)
            let titleSize = min(geometry.size.width * 0.08, 32)
            let subtitleSize = min(geometry.size.width * 0.043, 17)
            
            VStack(spacing: 0) {
                // Top spacing (responsive)
                Spacer()
                    .frame(height: geometry.size.height * 0.08)
                
                // Icon with animated glow (responsive)
                ZStack {
                    // Glow background
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: glowSize, height: glowSize)
                        .blur(radius: isSmallScreen ? 15 : 20)
                    
                    // Icon container (responsive)
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
                            .frame(width: iconContainerSize, height: iconContainerSize)
                        
                        Image(systemName: icon)
                            .font(.system(size: iconFontSize, weight: .medium))
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
                .padding(.bottom, min(geometry.size.height * 0.04, 32))
                
                // Title (responsive)
                Text(title)
                    .font(.system(size: titleSize, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, geometry.size.width * 0.08)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Subtitle (responsive)
                Text(subtitle)
                    .font(.system(size: subtitleSize, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(isSmallScreen ? 3 : 4)
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.top, min(geometry.size.height * 0.015, 12))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Custom content (responsive)
                content
                    .padding(.top, min(geometry.size.height * 0.04, 32))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                Spacer()
                
                // Bottom content (buttons) (responsive)
                bottomContent
                    .padding(.horizontal, geometry.size.width * 0.07)
                    .padding(.bottom, min(geometry.size.height * 0.12, 100))
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
    let style: InstructionCardStyle
    
    public init(steps: [InstructionItem], style: InstructionCardStyle = .light()) {
        self.steps = steps
        self.style = style
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.width < 380
            let circleSize: CGFloat = isSmallScreen ? 28 : 32
            let numberFontSize: CGFloat = isSmallScreen ? 13 : 15
            let textFontSize: CGFloat = isSmallScreen ? 14 : 16
            let spacing: CGFloat = isSmallScreen ? 12 : 16
            
            VStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: spacing) {
                        // Step number with gradient (responsive)
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: style.numberGradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: circleSize, height: circleSize)
                            
                            Text("\(index + 1)")
                                .font(.system(size: numberFontSize, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                        
                        Text(step.text)
                            .font(.system(size: textFontSize, weight: .medium, design: .default))
                            .foregroundColor(style.textColor)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(.vertical, isSmallScreen ? 12 : 14)
                    
                    if index < steps.count - 1 {
                        Divider()
                            .background(style.dividerColor)
                            .padding(.leading, circleSize + spacing)
                    }
                }
            }
            .padding(.horizontal, isSmallScreen ? 16 : 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(style.background)
                    .shadow(color: style.shadowColor, radius: style.shadowRadius, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .frame(height: CGFloat(steps.count) * 56 + 16)
        .padding(.horizontal, 24)
    }
}

public struct InstructionCardStyle {
    public let background: Color
    public let textColor: Color
    public let numberGradientColors: [Color]
    public let dividerColor: Color
    public let borderColor: Color
    public let borderWidth: CGFloat
    public let shadowColor: Color
    public let shadowRadius: CGFloat
    
    public init(
        background: Color,
        textColor: Color,
        numberGradientColors: [Color],
        dividerColor: Color,
        borderColor: Color,
        borderWidth: CGFloat,
        shadowColor: Color,
        shadowRadius: CGFloat
    ) {
        self.background = background
        self.textColor = textColor
        self.numberGradientColors = numberGradientColors
        self.dividerColor = dividerColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
    }
    
    public static func light(accentColors: [Color] = [Color.blue, Color.blue.opacity(0.7)]) -> InstructionCardStyle {
        InstructionCardStyle(
            background: Color.white,
            textColor: Color(red: 0.2, green: 0.2, blue: 0.25),
            numberGradientColors: accentColors,
            dividerColor: Color.gray.opacity(0.2),
            borderColor: Color.clear,
            borderWidth: 0,
            shadowColor: Color.black.opacity(0.06),
            shadowRadius: 12
        )
    }
    
    public static func dark(accentColors: [Color]) -> InstructionCardStyle {
        InstructionCardStyle(
            background: Color.white.opacity(0.08),
            textColor: Color(red: 0.85, green: 0.85, blue: 0.9),
            numberGradientColors: accentColors,
            dividerColor: Color.white.opacity(0.2),
            borderColor: Color.white.opacity(0.15),
            borderWidth: 1,
            shadowColor: Color.clear,
            shadowRadius: 0
        )
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
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.width < 380
            let iconSize: CGFloat = isSmallScreen ? 18 : 20
            let textSize: CGFloat = isSmallScreen ? 14 : 16
            let spacing: CGFloat = isSmallScreen ? 12 : 14
            
            HStack(spacing: spacing) {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(color)
                
                Text(text)
                    .font(.system(size: textSize, weight: .medium, design: .default))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
        .frame(height: 28)
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
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.width < 380
            let titleSize: CGFloat = isSmallScreen ? 15 : 17
            let iconSize: CGFloat = isSmallScreen ? 13 : 15
            let buttonHeight: CGFloat = isSmallScreen ? 50 : 56
            let spacing: CGFloat = isSmallScreen ? 8 : 10
            
            Button(action: action) {
                HStack(spacing: spacing) {
                    Text(title)
                        .font(.system(size: titleSize, weight: .semibold, design: .default))
                    
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: iconSize, weight: .semibold))
                    }
                }
                .foregroundColor(style == .primary ? .white : Color.blue)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
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
                .cornerRadius(isSmallScreen ? 14 : 16)
                .shadow(
                    color: style == .primary ? Color.blue.opacity(0.3) : Color.clear,
                    radius: isSmallScreen ? 10 : 12,
                    x: 0,
                    y: isSmallScreen ? 4 : 6
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(height: 56)
    }
}

struct ScaleButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
