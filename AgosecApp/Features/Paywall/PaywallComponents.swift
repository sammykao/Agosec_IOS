import SwiftUI

// MARK: - Paywall Feature Row

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let geometry: GeometryProxy
    
    var body: some View {
        let isSmallScreen = geometry.size.width < 380
        let iconContainerSize = min(geometry.size.width * 0.11, 44)
        let iconSize = min(geometry.size.width * 0.055, 22)
        
        HStack(spacing: isSmallScreen ? 12 : 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.25),
                                color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: iconContainerSize, height: iconContainerSize)
                
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(
                        size: min(geometry.size.width * 0.04, 16),
                        weight: .semibold,
                        design: .default
                    ))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))
                    .lineLimit(1)
                
                Text(description)
                    .font(.system(
                        size: min(geometry.size.width * 0.035, 14),
                        weight: .regular,
                        design: .default
                    ))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: isSmallScreen ? 18 : 20))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

// MARK: - Paywall Background

struct PaywallBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.05, blue: 0.08),
                Color(red: 0.08, green: 0.08, blue: 0.12),
                Color(red: 0.06, green: 0.06, blue: 0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Paywall Floating Orbs

struct PaywallFloatingOrbs: View {
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.12 - Double(index) * 0.03),
                                Color.orange.opacity(0.08 - Double(index) * 0.02),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 120 + CGFloat(index) * 60
                        )
                    )
                    .frame(
                        width: min(200 + CGFloat(index) * 80, geometry.size.width * 0.6),
                        height: min(200 + CGFloat(index) * 80, geometry.size.width * 0.6)
                    )
                    .blur(radius: 50)
                    .offset(
                        x: max(-geometry.size.width * 0.3, min(geometry.size.width * 0.3, CGFloat(index) * 60 - 100)),
                        y: max(-geometry.size.height * 0.2, min(geometry.size.height * 0.2, CGFloat(index) * 80 - 100))
                    )
                    .opacity(0.7)
            }
        }
    }
}

// MARK: - Paywall Header

struct PaywallHeader: View {
    let geometry: GeometryProxy
    let iconScale: CGFloat
    let iconOpacity: Double
    let glowOpacity: Double
    let contentOpacity: Double
    let contentOffset: CGFloat
    
    var body: some View {
        let isSmallScreen = geometry.size.width < 380
        let iconSize = min(geometry.size.width * 0.18, 72)
        let containerSize = iconSize * 1.4
        
        VStack(spacing: min(geometry.size.height * 0.02, 16)) {
            // Crown icon with glow
            ZStack {
                // Glow rings
                ForEach(0..<2) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.5 - Double(index) * 0.25),
                                    Color.orange.opacity(0.4 - Double(index) * 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSmallScreen ? 1.5 : 2
                        )
                        .frame(
                            width: containerSize + CGFloat(index) * 20,
                            height: containerSize + CGFloat(index) * 20
                        )
                        .opacity(glowOpacity * (1.0 - Double(index) * 0.4))
                }
                
                // Icon container
                Circle()
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                    .frame(width: containerSize, height: containerSize)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 15)
                    .shadow(color: Color.yellow.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Crown icon
                Image(systemName: "crown.fill")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
            
            // Title
            Text("Unlock Agosec")
                .font(.system(
                    size: min(geometry.size.width * 0.09, 36),
                    weight: .bold,
                    design: .default
                ))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.yellow.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.yellow.opacity(0.3), radius: 15, x: 0, y: 8)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Subtitle
            Text("Get access to AI-powered typing assistance")
                .font(.system(
                    size: min(geometry.size.width * 0.043, 17),
                    weight: .regular,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                .multilineTextAlignment(.center)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
        }
        .padding(.horizontal, geometry.size.width * 0.08)
    }
}

// MARK: - Paywall Subscribe Button

struct PaywallSubscribeButton: View {
    let geometry: GeometryProxy
    let isLoading: Bool
    let shimmerOffset: CGFloat
    let action: () -> Void
    
    var body: some View {
        let isSmallScreen = geometry.size.width < 380
        let buttonHeight: CGFloat = isSmallScreen ? 54 : 60
        
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Subscribe Now")
                        .font(.system(size: isSmallScreen ? 17 : 19, weight: .semibold, design: .default))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: isSmallScreen ? 15 : 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(
                ZStack {
                    // Gradient base
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.48, blue: 1.0),
                            Color(red: 0.58, green: 0.0, blue: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // Glassmorphic overlay
                    Color.white.opacity(0.15)
                    
                    // Shimmer effect
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 200)
                    .offset(x: shimmerOffset)
                }
            )
            .cornerRadius(isSmallScreen ? 18 : 20)
            .overlay(
                RoundedRectangle(cornerRadius: isSmallScreen ? 18 : 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.blue.opacity(0.5), radius: 25, x: 0, y: 12)
            .shadow(color: Color.purple.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
}

// MARK: - Paywall Terms Section

struct PaywallTermsSection: View {
    let geometry: GeometryProxy
    let openTerms: () -> Void
    let openPrivacyPolicy: () -> Void
    
    var body: some View {
        let isSmallScreen = geometry.size.width < 380
        
        VStack(spacing: isSmallScreen ? 6 : 8) {
            Text("Cancel anytime in Settings")
                .font(.system(
                    size: min(geometry.size.width * 0.03, 12),
                    weight: .regular,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
            
            HStack(spacing: isSmallScreen ? 12 : 16) {
                Button("Terms of Service") {
                    openTerms()
                }
                .font(.system(
                    size: min(geometry.size.width * 0.03, 12),
                    weight: .medium,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.8))
                
                Text("•")
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                
                Button("Privacy Policy") {
                    openPrivacyPolicy()
                }
                .font(.system(
                    size: min(geometry.size.width * 0.03, 12),
                    weight: .medium,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.8))
            }
        }
    }
}
