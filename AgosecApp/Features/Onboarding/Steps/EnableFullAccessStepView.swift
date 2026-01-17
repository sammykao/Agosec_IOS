import SwiftUI
import UIComponents

struct EnableFullAccessStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var hasFullAccess = false
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var glowOpacity: Double = 0.3
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top spacing to push content down
                Spacer()
                    .frame(maxHeight: geometry.size.height * 0.1)
                
                // Animated icon with modern design (responsive)
                let iconSize = min(geometry.size.width * 0.22, 90)
                let ringBaseSize = min(geometry.size.width * 0.25, 100)
                
                ZStack {
                    // Animated glow rings (responsive)
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.4 - Double(index) * 0.2),
                                        Color.orange.opacity(0.15 - Double(index) * 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: geometry.size.width < 380 ? 1.5 : 2
                            )
                            .frame(width: ringBaseSize + CGFloat(index) * 16, height: ringBaseSize + CGFloat(index) * 16)
                            .scaleEffect(1.0 + CGFloat(index) * 0.1)
                            .opacity(glowOpacity * (1.0 - Double(index) * 0.3))
                    }
                    
                    // Icon background with glassmorphism (responsive)
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.25),
                                        Color.orange.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: iconSize, height: iconSize)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.4),
                                        Color.orange.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: iconSize, height: iconSize)
                    }
                    
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: min(geometry.size.width * 0.1, 40), weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .padding(.bottom, min(geometry.size.height * 0.03, 24))
                
                // Title (responsive)
                Text("Allow Full Access")
                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color(red: 1.0, green: 0.58, blue: 0.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Subtitle (responsive)
                Text("Full access enables AI features and secure communication")
                    .font(.system(size: min(geometry.size.width * 0.043, 17), weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.top, min(geometry.size.height * 0.015, 12))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Instructions card (responsive)
                instructionsCard(in: geometry)
                    .padding(.top, min(geometry.size.height * 0.03, 24))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    if hasFullAccess {
                        // Full access enabled - show Continue as primary
                        ModernActionButton(
                            title: "Continue",
                            icon: "arrow.right",
                            action: onNext
                        )
                        
                        Text("Full access enabled!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    } else {
                        // Full access not enabled - show Open Settings
                        ModernActionButton(
                            title: "Open Settings",
                            icon: "gear",
                            action: openSettings
                        )
                        
                        Text("After enabling, type something to activate, then return")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        // Manual continue option
                        Button {
                            DispatchQueue.main.async {
                                onNext()
                            }
                        } label: {
                            Text("I've enabled full access →")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 80) // Account for page indicator
                .opacity(contentOpacity)
                .offset(y: contentOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startAnimations()
            checkFullAccessStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                checkFullAccessStatus()
            }
        }
    }
    
    private func instructionsCard(in geometry: GeometryProxy) -> some View {
        let isSmallScreen = geometry.size.width < 380
        let circleSize: CGFloat = isSmallScreen ? 28 : 32
        let fontSize: CGFloat = isSmallScreen ? 13 : 15
        let spacing: CGFloat = isSmallScreen ? 12 : 16
        
        return VStack(spacing: 0) {
            ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(spacing: spacing) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: circleSize, height: circleSize)
                        
                        Text("\(index + 1)")
                            .font(.system(size: fontSize, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    Text(instruction)
                        .font(.system(size: fontSize, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding(.vertical, isSmallScreen ? 10 : 12)
                
                if index < instructions.count - 1 {
                    Divider()
                        .padding(.leading, circleSize + spacing)
                }
            }
        }
        .padding(.horizontal, isSmallScreen ? 16 : 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, geometry.size.width * 0.06)
    }
    
    private var instructions: [String] {
        [
            "Open Settings → General → Keyboard",
            "Tap \"Keyboards\" → \"Agosec Keyboard\"",
            "Toggle on \"Allow Full Access\""
        ]
    }
    
    private func startAnimations() {
        // Icon entrance
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        // Continuous glow animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.7
            }
        }
        
        // Content entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func checkFullAccessStatus() {
        hasFullAccess = permissionsService.hasFullAccess
    }
}
