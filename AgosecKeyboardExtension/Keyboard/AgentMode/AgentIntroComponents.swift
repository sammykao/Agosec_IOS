import SwiftUI
import UIKit
import UIComponents

struct AgentIntroHeaderSection: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("Start Your Session")
                .font(.system(
                    size: ResponsiveSystem.value(extraSmall: 20, small: 22, standard: 24),
                    weight: .semibold,
                    design: .default
                ))
                .tracking(0.2)
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                .multilineTextAlignment(.center)
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
        HStack(spacing: ResponsiveSystem.value(extraSmall: 10, small: 12, standard: 16)) {
            squareButton(
                title: "Use Context",
                subtitle: "Screenshots",
                systemImage: "photo.badge.plus",
                accent: Color(red: 0.1, green: 0.4, blue: 0.75),
                action: onUseScreenshots
            )
            squareButton(
                title: "Skip Context",
                subtitle: "Start fresh",
                systemImage: "message.circle",
                accent: Color(red: 0.55, green: 0.2, blue: 0.7),
                action: onContinue
            )
        }
    }

    private func squareButton(
        title: String,
        subtitle: String,
        systemImage: String,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(accent)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(accent.opacity(0.15))
                    )

                VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.4))
            }
        }
            .frame(maxWidth: .infinity, minHeight: 92)
            .padding(8)
            .background(
                accent.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.6),
                                Color.black.opacity(0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
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
