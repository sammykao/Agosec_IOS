import SwiftUI
import UIKit
import SharedCore
import UIComponents

struct OnboardingCoordinator: View {
    @ObservedObject var router: AppRouter
    @State private var currentStep: OnboardingStep = .welcome
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case enableKeyboard = 1
        case enableFullAccess = 2
        case photosPermission = 3
        case demo = 4
        
        static var totalSteps: Int {
            allCases.count
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.97, green: 0.97, blue: 0.99)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Main content area
            Group {
                switch currentStep {
                case .welcome:
                    WelcomeStepView(onNext: { currentStep = .enableKeyboard })
                case .enableKeyboard:
                    EnableKeyboardStepView(onNext: { currentStep = .enableFullAccess })
                case .enableFullAccess:
                    EnableFullAccessStepView(onNext: { currentStep = .photosPermission })
                case .photosPermission:
                    PhotosPermissionStepView(onNext: { currentStep = .demo })
                case .demo:
                    DemoConversationStepView(onComplete: {
                        AppGroupStorage.shared.set(true, for: "onboarding_complete")
                        router.navigateTo(.paywall)
                    })
                }
            }
            
            // Page indicator overlaid at the bottom
            VStack {
                Spacer()
                PageIndicator(
                    currentPage: currentStep.rawValue,
                    totalPages: OnboardingStep.totalSteps
                )
                .padding(.bottom, 44)
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
}

// MARK: - Welcome Step View

struct WelcomeStepView: View {
    let onNext: () -> Void
    
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0.0
    @State private var logoGlow: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 40
    @State private var buttonOpacity: Double = 0.0
    @State private var buttonOffset: CGFloat = 30
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: geometry.size.height * 0.12)
                
                // Logo with glow effect
                ZStack {
                    // Animated glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.2 * logoGlow),
                                    Color.purple.opacity(0.1 * logoGlow),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // Logo
                    Group {
                        if let uiImage = UIImage(named: "agosec_logo") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: "keyboard")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .frame(width: 120, height: 120)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(y: floatOffset)
                    .shadow(color: Color.blue.opacity(0.2), radius: 30, x: 0, y: 15)
                }
                .padding(.bottom, 48)
                
                // Welcome text
                VStack(spacing: 16) {
                    Text("Welcome to")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                    
                    Text("Agosec")
                        .font(.system(size: 52, weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.1, green: 0.1, blue: 0.15),
                                    Color(red: 0.2, green: 0.25, blue: 0.35)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Your AI-powered keyboard that understands context and helps you communicate smarter.")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.4))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
                
                Spacer()
                
                // Features preview
                VStack(spacing: 14) {
                    FeatureHighlight(icon: "brain.head.profile", text: "Context-aware AI")
                    FeatureHighlight(icon: "bolt.fill", text: "Instant responses")
                    FeatureHighlight(icon: "lock.shield", text: "Privacy focused")
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
                .padding(.bottom, 40)
                
                // Get Started button
                VStack(spacing: 12) {
                    Button(action: onNext) {
                        HStack(spacing: 10) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(18)
                        .shadow(color: Color.blue.opacity(0.35), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 32)
                }
                .opacity(buttonOpacity)
                .offset(y: buttonOffset)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Logo glow
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            logoGlow = 1.0
        }
        
        // Logo float
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            floatOffset = -6
        }
        
        // Text entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                textOpacity = 1.0
                textOffset = 0
            }
        }
        
        // Button entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                buttonOpacity = 1.0
                buttonOffset = 0
            }
        }
    }
}

// MARK: - Feature Highlight

struct FeatureHighlight: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
        }
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
