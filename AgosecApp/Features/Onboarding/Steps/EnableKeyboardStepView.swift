import SwiftUI
import UIKit
import SharedCore
import UIComponents

struct EnableKeyboardStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var isKeyboardEnabled = false
    @State private var pulseScale: CGFloat = 1.0
    let onNext: () -> Void

    var body: some View {
        OnboardingStepScaffold(
            topSpacing: { geometry in
                ResponsiveSystem.isShortScreen
                    ? max(geometry.size.height * 0.12, 60)
                    : max(geometry.size.height * 0.08, 40)
            },
            header: { geometry, state in
                let ringBaseSize = ResponsiveSystem.isSmallScreen
                    ? 90
                    : min(geometry.size.width * 0.28, 100)

                return ZStack {
                    // Animated pulse rings (responsive)
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
                                lineWidth: ResponsiveSystem.isSmallScreen ? 1.5 : 2
                            )
                            .frame(
                                width: ringBaseSize + CGFloat(index) * 16,
                                height: ringBaseSize + CGFloat(index) * 16
                            )
                            .scaleEffect(pulseScale + CGFloat(index) * 0.1)
                            .opacity(state.headerOpacity * (1.0 - Double(index) * 0.3))
                    }

                    // Icon background with glassmorphism (responsive)
                    Circle()
                        .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
                        .frame(
                            width: ResponsiveSystem.isSmallScreen ? 110 : min(geometry.size.width * 0.3, 130),
                            height: ResponsiveSystem.isSmallScreen ? 110 : min(geometry.size.width * 0.3, 130)
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
                        .font(.system(
                            size: ResponsiveSystem.isSmallScreen ? 42 : min(geometry.size.width * 0.12, 48),
                            weight: .medium
                        ))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(state.headerScale)
                .opacity(state.headerOpacity)
                .padding(.bottom, ResponsiveSystem.isShortScreen
                    ? min(geometry.size.height * 0.05, 40)
                    : min(geometry.size.height * 0.04, 32)
                )
            },
            bodyContent: { geometry, _ in
                VStack(spacing: 0) {
                    // Title (Bold & Expressive - Responsive)
                    Text("Enable Keyboard")
                        .font(.system(
                            size: ResponsiveSystem.isSmallScreen ? 32 : min(geometry.size.width * 0.12, 40),
                            weight: .bold,
                            design: .default
                        ))
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
                        .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
                        .padding(.bottom, ResponsiveSystem.isShortScreen ? 6 : 8)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.center)

                    // Subtitle in glassmorphic container (Responsive)
                    Text("Add Agosec to your keyboards to start using AI-powered typing")
                        .font(.system(
                            size: ResponsiveSystem.isSmallScreen ? 16 : min(geometry.size.width * 0.045, 18),
                            weight: .regular,
                            design: .default
                        ))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 18 : min(geometry.size.width * 0.06, 24))
                        .padding(.vertical, ResponsiveSystem.isShortScreen ? 12 : 16)
                        .background(
                            Color.white.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: ResponsiveSystem.isSmallScreen ? 18 : 20)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: ResponsiveSystem.isSmallScreen ? 18 : 20)
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
                        .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : min(geometry.size.width * 0.06, 24))

                    // Instructions card (Glassmorphic - Responsive)
                    ModernInstructionCard(
                        steps: instructionItems,
                        style: .dark(accentColors: [Color.blue, Color.blue.opacity(0.8)])
                    )
                    .padding(.top, ResponsiveSystem.isShortScreen
                        ? min(geometry.size.height * 0.03, 24)
                        : min(geometry.size.height * 0.04, 32)
                    )
                }
            },
            footer: { geometry, _ in
                VStack(spacing: 12) {
                    if isKeyboardEnabled {
                        ModernActionButton(
                            title: "Continue",
                            icon: "arrow.right",
                            action: onNext
                        )

                        Text("Keyboard enabled!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    } else {
                        ModernActionButton(
                            title: "Open Settings",
                            icon: "gear",
                            action: openSettings
                        )

                        Text("Go to General → Keyboard → Keyboards")
                            .font(.system(
                                size: min(geometry.size.width * 0.033, 13),
                                weight: .regular,
                                design: .default
                            ))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.horizontal, min(geometry.size.width * 0.07, 28))
            },
            onAppear: {
                startPulseAnimation()
                checkKeyboardStatus()
            }
        )
        .onAppBecameActive {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                checkKeyboardStatus()
            }
        }
    }

    private var instructionItems: [InstructionItem] {
        AccessCopy.enableKeyboardSteps.map { InstructionItem(text: $0) }
    }

    private func startPulseAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func checkKeyboardStatus() {
        permissionsService.refreshStatus()
        isKeyboardEnabled = permissionsService.isKeyboardExtensionEnabled
    }
}
