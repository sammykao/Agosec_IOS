import SwiftUI
import UIKit
import UIComponents

struct AgentIntroHeaderSection: View {
    let logoScale: CGFloat
    let logoOpacity: Double
    let logoFloat: CGFloat

    var body: some View {
        let circleSize: CGFloat = ResponsiveSystem.value(extraSmall: 180, small: 200, standard: 220)
        let logoSize: CGFloat = ResponsiveSystem.value(extraSmall: 120, small: 140, standard: 160)

        return VStack(spacing: ResponsiveSystem.value(extraSmall: 10, small: 12, standard: 16)) {
            logoView(circleSize: circleSize, logoSize: logoSize)
            headerTextSection
        }
        .padding(.top, ResponsiveSystem.value(
            extraSmall: 6,
            small: 8,
            standard: 12
        ))
        .padding(.bottom, ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10))
        .frame(maxWidth: .infinity)
    }

    private func logoView(circleSize: CGFloat, logoSize: CGFloat) -> some View {
        ZStack {
            glowRings(circleSize: circleSize)
            logoContainer(circleSize: circleSize)
            logoImage(logoSize: logoSize)
        }
    }

    @ViewBuilder
    private func glowRings(circleSize: CGFloat) -> some View {
        // Outer glow rings (matching splash screen)
        ForEach(0..<2) { index in
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.48, blue: 1.0).opacity(max(0.0, 0.4 - Double(index) * 0.2)),
                            Color(red: 0.58, green: 0.0, blue: 1.0).opacity(max(0.0, 0.3 - Double(index) * 0.15))
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: circleSize + CGFloat(index) * 20, height: circleSize + CGFloat(index) * 20)
                .scaleEffect(1.0 + CGFloat(index) * 0.1)
                .opacity(logoOpacity * (1.0 - Double(index) * 0.3))
        }
    }

    private func logoContainer(circleSize: CGFloat) -> some View {
        // Dark container for white logo (matching splash screen) - BIGGER
        Circle()
            .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
            .frame(width: circleSize, height: circleSize)
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
            .shadow(color: Color.black.opacity(0.5), radius: 50, x: 0, y: 25)
            .shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 15)
            .opacity(logoOpacity)
    }

    private func logoImage(logoSize: CGFloat) -> some View {
        // Logo (matching splash screen pattern) - SMALLER to fit inside circle
        Group {
            if let uiImage = LogoLoader.loadAgosecLogo() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: logoSize, height: logoSize)
            } else {
                Image(systemName: "sparkles")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: logoSize, height: logoSize)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0),
                                Color(red: 0.58, green: 0.0, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
        .offset(y: logoFloat)
    }

    private var headerTextSection: some View {
        VStack(spacing: 8) {
            Text("How can I help?")
                .font(.system(
                    size: ResponsiveSystem.value(extraSmall: 20, small: 22, standard: 24),
                    weight: .bold,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                .multilineTextAlignment(.center)

            Text("Choose how to start your AI session")
                .font(.system(
                    size: ResponsiveSystem.value(extraSmall: 14, small: 15, standard: 16),
                    weight: .regular,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                .multilineTextAlignment(.center)
        }
    }
}

struct AgentIntroChoiceButtonsSection: View {
    let onUseScreenshots: () -> Void
    let onContinue: () -> Void

    var body: some View {
        let iconSize: CGFloat = ResponsiveSystem.value(extraSmall: 18, small: 20, standard: 24)
        let iconContainerSize: CGFloat = ResponsiveSystem.value(extraSmall: 32, small: 36, standard: 40)

        return VStack(spacing: ResponsiveSystem.value(
            extraSmall: 10,
            small: 12,
            standard: 16
        )) {
            Button(action: onUseScreenshots) {
                HStack(spacing: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 16)) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                        .frame(width: iconContainerSize, height: iconContainerSize)
                        .background(
                            Circle()
                                .fill(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.15))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Use Screenshots")
                            .font(.system(
                                size: ResponsiveSystem.value(extraSmall: 15, small: 16, standard: 17),
                                weight: .semibold,
                                design: .default
                            ))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        Text("Import screenshots for context")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    }

                    Spacer()
                }
                .padding(ResponsiveSystem.value(
                    extraSmall: 12,
                    small: 14,
                    standard: 20
                ))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ScaleButtonStyle())

            Button(action: onContinue) {
                HStack(spacing: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 16)) {
                    Image(systemName: "message.circle")
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(Color(red: 0.58, green: 0.0, blue: 1.0))
                        .frame(width: iconContainerSize, height: iconContainerSize)
                        .background(
                            Circle()
                                .fill(Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.15))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Continue without Context")
                            .font(.system(
                                size: ResponsiveSystem.value(extraSmall: 15, small: 16, standard: 17),
                                weight: .semibold,
                                design: .default
                            ))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        Text("Start fresh conversation")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    }

                    Spacer()
                }
                .padding(ResponsiveSystem.value(
                    extraSmall: 12,
                    small: 14,
                    standard: 20
                ))
                .frame(maxWidth: .infinity)
                .background(
                    Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: ResponsiveSystem.value(
                        extraSmall: 14,
                        small: 16,
                        standard: 20
                    ))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ResponsiveSystem.value(
                        extraSmall: 14,
                        small: 16,
                        standard: 20
                    ))
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
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

struct AgentIntroTipsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
                Text("Tips")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .top, spacing: 4) {
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("Screenshots are optional")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 4) {
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("Import 1-5 screenshots")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 4) {
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("Context helps AI")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.white.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.58, blue: 0.0).opacity(0.3),
                            Color(red: 1.0, green: 0.58, blue: 0.0).opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
