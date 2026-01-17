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
                Spacer()
                    .frame(height: geometry.size.height * 0.08)
                
                // Animated icon
                ZStack {
                    // Pulse effect
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                    
                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.15), Color.blue.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "keyboard.badge.ellipsis")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .padding(.bottom, 32)
                
                // Title
                Text("Enable Keyboard")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Subtitle
                Text("Add Agosec to your keyboards to start using AI-powered typing")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .padding(.top, 12)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Instructions card
                instructionsCard
                    .padding(.top, 32)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 14) {
                    ModernActionButton(
                        title: "Open Settings",
                        icon: "arrow.up.right",
                        action: openSettings
                    )
                    
                    if isKeyboardEnabled {
                        ModernActionButton(
                            title: "Continue",
                            icon: "arrow.right",
                            action: onNext
                        )
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 100)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
            }
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
    
    private var instructionsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 15, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    Text(instruction)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Spacer()
                }
                .padding(.vertical, 14)
                
                if index < instructions.count - 1 {
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
    
    private var instructions: [String] {
        ["Tap Open Settings", "Tap Keyboards", "Enable Agosec Keyboard"]
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        
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
