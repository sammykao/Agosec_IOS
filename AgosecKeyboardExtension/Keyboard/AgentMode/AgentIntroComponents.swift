import SwiftUI
import UIKit
import UIComponents

struct AgentIntroTheme {
    static let accentBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let accentPurple = Color(red: 0.58, green: 0.0, blue: 1.0)
    static let accentCyan = Color(red: 0.1, green: 0.75, blue: 0.95)

    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.7)

    static let glassFill = Color.white.opacity(0.08)
    static let glassHighlight = Color.white.opacity(0.14)
    static let glassBorder = Color.white.opacity(0.18)

    static let cardBorder = LinearGradient(
        colors: [
            accentBlue.opacity(0.55),
            accentPurple.opacity(0.45),
            Color.white.opacity(0.2)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGlow = RadialGradient(
        colors: [
            accentBlue.opacity(0.2),
            accentPurple.opacity(0.12),
            Color.clear
        ],
        center: .topLeading,
        startRadius: 10,
        endRadius: 180
    )
}

struct AgentIntroHeaderSection: View {
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(AgentIntroTheme.accentBlue.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .blur(radius: 18)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AgentIntroTheme.accentBlue.opacity(0.25),
                                AgentIntroTheme.accentPurple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                    .overlay(
                        Circle()
                            .stroke(AgentIntroTheme.glassBorder, lineWidth: 1)
                    )

                if let logoImage = LogoLoader.loadAgosecLogo() {
                    Image(uiImage: logoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .shadow(color: AgentIntroTheme.accentBlue.opacity(0.35), radius: 8, x: 0, y: 4)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AgentIntroTheme.accentCyan,
                                    AgentIntroTheme.accentBlue
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }

            Text("Start Your Session")
                .font(.system(
                    size: ResponsiveSystem.value(extraSmall: 20, small: 22, standard: 24),
                    weight: .semibold,
                    design: .default
                ))
                .tracking(0.3)
                .foregroundColor(AgentIntroTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Add context from your screenshots or jump straight in.")
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(AgentIntroTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(.top, ResponsiveSystem.value(
            extraSmall: 6,
            small: 8,
            standard: 12
        ))
        .padding(.bottom, ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10))
        .frame(maxWidth: .infinity)
    }
}

struct AgentIntroChoiceButtonsSection: View {
    let onUseScreenshots: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            actionButton(
                title: "Use Screenshots",
                subtitle: "Add context from your recent images",
                systemImage: "photo.badge.plus",
                accent: AgentIntroTheme.accentBlue,
                isPrimary: true,
                action: onUseScreenshots
            )
            actionButton(
                title: "Start Without Context",
                subtitle: "Begin a fresh conversation",
                systemImage: "message.circle",
                accent: AgentIntroTheme.accentPurple,
                isPrimary: false,
                action: onContinue
            )
        }
    }

    private func actionButton(
        title: String,
        subtitle: String,
        systemImage: String,
        accent: Color,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent, accent.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [accent.opacity(0.22), accent.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(AgentIntroTheme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(AgentIntroTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AgentIntroTheme.textSecondary.opacity(0.8))
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.opacity(isPrimary ? 0.25 : 0.18),
                                AgentIntroTheme.glassFill
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accent.opacity(isPrimary ? 0.75 : 0.6),
                                AgentIntroTheme.glassBorder
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.7)
                    .blendMode(.screen)
            )
            .shadow(color: accent.opacity(isPrimary ? 0.25 : 0.18), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
