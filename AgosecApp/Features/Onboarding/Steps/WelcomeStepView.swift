import SwiftUI
import UIKit
import UIComponents

// MARK: - Welcome Step View

struct WelcomeStepView: View {
    let onNext: () -> Void

    @State var logoScale: CGFloat = 0.3
    @State var logoOpacity: Double = 0.0
    @State var logoFloat: CGFloat = 0
    @State var logoGlow: Double = 0.0

    @State var textOpacity: Double = 0.0
    @State var textOffset: CGFloat = 30
    @State var textScale: CGFloat = 0.9

    @State var buttonOpacity: Double = 0.0
    @State var buttonScale: CGFloat = 0.9
    @State var shimmerOffset: CGFloat = -300

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Push content down - weighted spacer (more on short screens)
                Spacer()
                    .frame(
                        maxHeight: ResponsiveSystem.isShortScreen
                            ? max(geometry.size.height * 0.12, 50)
                            : max(geometry.size.height * 0.15, 60)
                    )

                // Glassmorphic logo container (responsive)
                glassmorphicLogoSection(in: geometry)
                    .padding(.bottom, ResponsiveSystem.isShortScreen ? 24 : 32)

                // Bold welcome text in glassmorphic panel (responsive)
                glassmorphicTextSection(in: geometry)

                // Flexible space between content and button
                Spacer()
                    .frame(minHeight: ResponsiveSystem.isShortScreen ? 30 : 40)

                // Modern button with glassmorphic effects
                modernButtonSection(in: geometry)
                    .padding(.bottom, ResponsiveSystem.isShortScreen ? 60 : 80) // Account for page indicator
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Logo entrance
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Logo glow pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                logoGlow = 1.0
            }
        }

        // Logo float
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                logoFloat = -10
            }
        }

        // Text entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                textOpacity = 1.0
                textOffset = 0
                textScale = 1.0
            }
        }

        // Button entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                buttonOpacity = 1.0
            }
        }
    }
}
