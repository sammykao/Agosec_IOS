import SwiftUI
import UIKit
import SharedCore
import UIComponents

struct EnableFullAccessStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var glowOpacity: Double = 0.3
    let onNext: () -> Void

    var body: some View {
        OnboardingStepScaffold(
            topSpacing: { geometry in
                ResponsiveSystem.isShortScreen ? geometry.size.height * 0.08 : geometry.size.height * 0.1
            },
            header: { geometry, state in
                let iconSize = ResponsiveSystem.value(
                    extraSmall: 75,
                    small: 82,
                    standard: min(geometry.size.width * 0.22, 90)
                )
                let ringBaseSize = ResponsiveSystem.value(
                    extraSmall: 85,
                    small: 92,
                    standard: min(geometry.size.width * 0.25, 100)
                )

                return ZStack {
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
                                lineWidth: ResponsiveSystem.value(extraSmall: 1.5, small: 1.5, standard: 2)
                            )
                            .frame(
                                width: ringBaseSize + CGFloat(index) * 16,
                                height: ringBaseSize + CGFloat(index) * 16
                            )
                            .scaleEffect(1.0 + CGFloat(index) * 0.1)
                            .opacity(glowOpacity * (1.0 - Double(index) * 0.3))
                    }

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
                .scaleEffect(state.headerScale)
                .opacity(state.headerOpacity)
                .padding(.bottom, min(geometry.size.height * 0.03, 24))
            },
            bodyContent: { geometry, _ in
                VStack(spacing: 0) {
                    Text("Allow Full Access")
                        .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color(red: 1.0, green: 0.58, blue: 0.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Full access enables AI features and secure communication")
                        .font(.system(size: min(geometry.size.width * 0.043, 17), weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, geometry.size.width * 0.1)
                        .padding(.top, min(geometry.size.height * 0.015, 12))

                    ModernInstructionCard(
                        steps: instructionItems,
                        style: .dark(accentColors: [Color.orange, Color.orange.opacity(0.8)])
                    )
                    .padding(.top, min(geometry.size.height * 0.03, 24))
                }
            },
            footer: { _, _ in
                VStack(spacing: 12) {
                    if permissionsService.hasFullAccessState {
                        ModernActionButton(
                            title: "Continue",
                            icon: "arrow.right",
                            action: onNext
                        )

                        Text("Ready to continue!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    } else {
                        ModernActionButton(
                            title: "Open Settings",
                            icon: "gear",
                            action: openSettings
                        )

                        Text(permissionsService.hasOpenedFullAccessSettings
                            ? "Toggle on full access, then return here"
                            : "Tap to open Settings and enable full access")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.horizontal, 28)
            },
            onAppear: {
                startGlowAnimation()
                checkFullAccessStatus()
            }
        )
        .onAppBecameActive {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    checkFullAccessStatus()
                }
            }
        }
    }

    private var instructionItems: [InstructionItem] {
        AccessCopy.enableFullAccessSteps.map { InstructionItem(text: $0) }
    }

    private func startGlowAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.7
            }
        }
    }

    private func openSettings() {
        permissionsService.markFullAccessSettingsOpened()

        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func checkFullAccessStatus() {
        permissionsService.refreshStatus()
    }
}
