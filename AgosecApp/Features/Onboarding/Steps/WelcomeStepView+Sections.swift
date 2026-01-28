import SwiftUI
import UIKit
import UIComponents

extension WelcomeStepView {
    // MARK: - Glassmorphic Logo Section

    func glassmorphicLogoSection(in geometry: GeometryProxy) -> some View {
        let logoSize = ResponsiveSystem.value(
            extraSmall: 110,
            small: 120,
            standard: min(geometry.size.width * 0.35, 140)
        )
        let containerSize = logoSize * 1.3

        return ZStack {
            logoGlowRings(containerSize: containerSize)
            logoContainer(containerSize: containerSize)
            logoImage(size: logoSize)
        }
    }

    private func logoGlowRings(containerSize: CGFloat) -> some View {
        ForEach(0..<2) { index in
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.5 - Double(index) * 0.25),
                            Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.4 - Double(index) * 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .frame(width: containerSize + CGFloat(index) * 30, height: containerSize + CGFloat(index) * 30)
                .scaleEffect(1.0 + CGFloat(index) * 0.15)
                .opacity(logoGlow * (1.0 - Double(index) * 0.4))
        }
    }

    private func logoContainer(containerSize: CGFloat) -> some View {
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
            .shadow(color: Color.black.opacity(0.5), radius: 50, x: 0, y: 25)
            .shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 15)
            .opacity(logoOpacity)
    }

    private func logoImage(size: CGFloat) -> some View {
        Group {
            if let uiImage = UIImage(named: "agosec_logo") {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "sparkles")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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
        .frame(width: size, height: size)
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
        .offset(y: logoFloat)
    }

    // MARK: - Glassmorphic Text Section

    func glassmorphicTextSection(in geometry: GeometryProxy) -> some View {
        VStack(spacing: textSectionSpacing(in: geometry)) {
            welcomeTitle(in: geometry)
            welcomeBrand(in: geometry)
            welcomeTagline(in: geometry)
        }
        .padding(.horizontal, ResponsiveSystem.value(
            extraSmall: 24,
            small: min(geometry.size.width * 0.08, 32),
            standard: min(geometry.size.width * 0.08, 32)
        ))
    }

    private func textSectionSpacing(in geometry: GeometryProxy) -> CGFloat {
        ResponsiveSystem.isShortScreen
            ? min(geometry.size.height * 0.025, 20)
            : min(geometry.size.height * 0.03, 24)
    }

    private func welcomeTitle(in geometry: GeometryProxy) -> some View {
        Text("Welcome to")
            .font(.system(
                size: ResponsiveSystem.value(
                    extraSmall: 20,
                    small: 22,
                    standard: min(geometry.size.width * 0.06, 24)
                ),
                weight: .medium,
                design: .default
            ))
            .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
            .opacity(textOpacity)
            .offset(y: textOffset)
    }

    private func welcomeBrand(in geometry: GeometryProxy) -> some View {
        Text("Agosec")
            .font(.system(
                size: ResponsiveSystem.value(
                    extraSmall: 44,
                    small: 50,
                    standard: min(geometry.size.width * 0.18, 56)
                ),
                weight: .bold,
                design: .default
            ))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 0.0, green: 0.48, blue: 1.0),
                        Color(red: 0.58, green: 0.0, blue: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .scaleEffect(textScale)
            .opacity(textOpacity)
            .offset(y: textOffset)
            .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, ResponsiveSystem.value(extraSmall: 20, small: 24, standard: 24))
    }

    private func welcomeTagline(in geometry: GeometryProxy) -> some View {
        Text("Let's get started.")
            .font(.system(
                size: ResponsiveSystem.value(
                    extraSmall: 18,
                    small: 19,
                    standard: min(geometry.size.width * 0.05, 20)
                ),
                weight: .regular,
                design: .default
            ))
            .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
            .padding(.horizontal, ResponsiveSystem.value(
                extraSmall: 20,
                small: min(geometry.size.width * 0.06, 24),
                standard: min(geometry.size.width * 0.06, 24)
            ))
            .padding(.vertical, ResponsiveSystem.isShortScreen ? 12 : 14)
            .background(
                Color.white.opacity(0.1),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
            .opacity(textOpacity)
            .offset(y: textOffset)
    }

    // MARK: - Modern Button Section

    func modernButtonSection(in geometry: GeometryProxy) -> some View {
        Button(
            action: {
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()

                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    buttonScale = 0.95
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        buttonScale = 1.0
                    }
                    onNext()
                }
            },
            label: {
                modernButtonLabel(in: geometry)
            }
        )
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(buttonScale)
        .opacity(buttonOpacity)
        .padding(.horizontal, ResponsiveSystem.value(
            extraSmall: 24,
            small: min(geometry.size.width * 0.08, 32),
            standard: min(geometry.size.width * 0.08, 32)
        ))
    }

    private func modernButtonLabel(in geometry: GeometryProxy) -> some View {
        HStack(spacing: ResponsiveSystem.value(extraSmall: 10, small: 12, standard: 12)) {
            Text("Get Started")
                .font(.system(
                    size: ResponsiveSystem.value(extraSmall: 18, small: 19, standard: 20),
                    weight: .semibold,
                    design: .default
                ))

            Image(systemName: "arrow.right")
                .font(.system(
                    size: ResponsiveSystem.value(extraSmall: 16, small: 17, standard: 18),
                    weight: .semibold
                ))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: buttonHeight(in: geometry))
        .background(buttonBackground)
        .cornerRadius(22)
        .overlay(buttonOverlay)
        .shadow(color: Color.blue.opacity(0.5), radius: 30, x: 0, y: 15)
        .shadow(color: Color.purple.opacity(0.3), radius: 15, x: 0, y: 8)
    }

    private func buttonHeight(in geometry: GeometryProxy) -> CGFloat {
        ResponsiveSystem.value(
            extraSmall: 56,
            small: ResponsiveSystem.isShortScreen ? 60 : min(geometry.size.height * 0.08, 64),
            standard: ResponsiveSystem.isShortScreen ? 60 : min(geometry.size.height * 0.08, 64)
        )
    }

    private var buttonBackground: some View {
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
    }

    private var buttonOverlay: some View {
        RoundedRectangle(cornerRadius: 22)
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
    }
}
