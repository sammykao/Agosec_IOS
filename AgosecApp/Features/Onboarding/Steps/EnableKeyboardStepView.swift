import SwiftUI
import UIComponents

struct EnableKeyboardStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var isKeyboardEnabled = false
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var pulseScale: CGFloat = 1.0
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top spacing to prevent icon cutoff
                Spacer()
                    .frame(maxHeight: geometry.size.height * 0.08)
                
                // Animated icon with modern design (responsive)
                ZStack {
                    // Animated pulse rings (responsive)
                    let ringBaseSize = min(geometry.size.width * 0.28, 100)
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.3 - Double(index) * 0.15),
                                        Color.blue.opacity(0.1 - Double(index) * 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: geometry.size.width < 380 ? 1.5 : 2
                            )
                            .frame(width: ringBaseSize + CGFloat(index) * 16, height: ringBaseSize + CGFloat(index) * 16)
                            .scaleEffect(pulseScale + CGFloat(index) * 0.1)
                            .opacity(iconOpacity * (1.0 - Double(index) * 0.3))
                    }
                    
                    // Icon background with glassmorphism (responsive)
                    Circle()
                        .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
                        .frame(
                            width: min(geometry.size.width * 0.3, 130),
                            height: min(geometry.size.width * 0.3, 130)
                        )
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
                        .shadow(color: Color.blue.opacity(0.3), radius: 40, x: 0, y: 20)
                        .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                    
                        Image(systemName: "keyboard.badge.ellipsis")
                            .font(.system(size: min(geometry.size.width * 0.12, 48), weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .padding(.bottom, min(geometry.size.height * 0.04, 32))
                
                // Title (Bold & Expressive - Responsive)
                Text("Enable Keyboard")
                    .font(.system(size: min(geometry.size.width * 0.12, 40), weight: .bold, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 0.0, green: 0.48, blue: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
                
                // Subtitle in glassmorphic container (Responsive)
                Text("Add Agosec to your keyboards to start using AI-powered typing")
                    .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, min(geometry.size.width * 0.06, 24))
                    .padding(.vertical, 16)
                    .background(
                        Color.white.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .padding(.horizontal, min(geometry.size.width * 0.06, 24))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                    // Instructions card (Glassmorphic - Responsive)
                    instructionsCard(in: geometry)
                        .padding(.top, min(geometry.size.height * 0.04, 32))
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    Spacer(minLength: 20)
                    
                    // Buttons
                    VStack(spacing: 12) {
                        if isKeyboardEnabled {
                            // Keyboard is enabled - show Continue as primary
                            ModernActionButton(
                                title: "Continue",
                                icon: "arrow.right",
                                action: onNext
                            )
                            
                            Text("Keyboard enabled!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        } else {
                            // Keyboard not enabled - show Open Settings
                            ModernActionButton(
                                title: "Open Settings",
                                icon: "gear",
                                action: openSettings
                            )
                            
                            Text("Go to General → Keyboard → Keyboards")
                                .font(.system(size: min(geometry.size.width * 0.033, 13), weight: .regular, design: .default))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            // Skip option for users who already enabled
                            Button {
                                // Use DispatchQueue to avoid animation conflicts
                                DispatchQueue.main.async {
                                    onNext()
                                }
                            } label: {
                                Text("I've already added the keyboard →")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.07, 28))
                    .padding(.bottom, 80) // Account for page indicator
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startAnimations()
            checkKeyboardStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                checkKeyboardStatus()
            }
        }
    }
    
    private func instructionsCard(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(spacing: min(geometry.size.width * 0.04, 16)) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.48, blue: 1.0),
                                        Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: min(geometry.size.width * 0.09, 36), height: min(geometry.size.width * 0.09, 36))
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Text("\(index + 1)")
                            .font(.system(size: min(geometry.size.width * 0.04, 16), weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    Text(instruction)
                        .font(.system(size: min(geometry.size.width * 0.038, 15), weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                
                if index < instructions.count - 1 {
                    Divider()
                        .padding(.leading, min(geometry.size.width * 0.13, 52))
                }
            }
        }
        .padding(.horizontal, min(geometry.size.width * 0.06, 24))
        .padding(.vertical, 12)
        .background(
            Color.white.opacity(0.08),
            in: RoundedRectangle(cornerRadius: 24)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal, min(geometry.size.width * 0.06, 24))
    }
    
    private var instructions: [String] {
        [
            "Open Settings → General → Keyboard",
            "Tap \"Keyboards\" → \"Add New Keyboard\"",
            "Select \"Agosec Keyboard\""
        ]
    }
    
    private func startAnimations() {
        // Icon entrance with bounce
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        // Continuous pulse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
        }
        
        // Content entrance with stagger
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
    
    private func checkKeyboardStatus() {
        isKeyboardEnabled = permissionsService.isKeyboardExtensionEnabled
    }
}
