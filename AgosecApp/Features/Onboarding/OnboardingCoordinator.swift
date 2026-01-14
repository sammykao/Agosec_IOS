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
                        // Save onboarding completion
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

struct WelcomeStepView: View {
    let onNext: () -> Void
    
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var logoRotation: Double = -10
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0.0
    @State private var buttonOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Content centered vertically
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(geometry.size.height * 0.1, 60))
                    
                    // Logo with enhanced animation
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
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .frame(
                        width: min(geometry.size.width * 0.32, 140),
                        height: min(geometry.size.width * 0.32, 140)
                    )
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .rotationEffect(.degrees(logoRotation))
                    .shadow(color: Color.blue.opacity(0.15), radius: 30, x: 0, y: 15)
                    .shadow(color: Color.purple.opacity(0.1), radius: 20, x: 0, y: 10)
                    .shadow(color: Color.black.opacity(0.1), radius: 25, x: 0, y: 12)
                    .padding(.bottom, 40)
                    
                    // Welcome text directly on background - NO CARD
                    VStack(spacing: 14) {
                        Text("Agosec")
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.15, green: 0.15, blue: 0.2),
                                        Color(red: 0.2, green: 0.25, blue: 0.35)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Your AI-powered keyboard")
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 32)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                    .padding(.bottom, 48)
                    
                    Spacer()
                    
                    // Enhanced button with gradient
                    VStack(spacing: 10) {
                        Button(action: onNext) {
                            HStack(spacing: 8) {
                                Text("Get Started")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)
                            .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, max(geometry.size.width * 0.1, 24))
                        
                        Text("Tap to begin your journey")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.5))
                    }
                    .offset(y: buttonOffset)
                    .opacity(buttonOpacity)
                    .padding(.bottom, max(geometry.size.height * 0.15, 80))
                }
            }
        }
        .onAppear {
            // Logo entrance with bounce
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
                logoRotation = 0
            }
            
            // Text entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    textOffset = 0
                    textOpacity = 1.0
                }
            }
            
            // Button entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    buttonOffset = 0
                    buttonOpacity = 1.0
                }
            }
        }
    }
}