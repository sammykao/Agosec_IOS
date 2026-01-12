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
            // Background gradient matching app theme
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
            
            VStack(spacing: 0) {
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Page indicator at the bottom
                VStack(spacing: 16) {
                    PageIndicator(
                        currentPage: currentStep.rawValue,
                        totalPages: OnboardingStep.totalSteps
                    )
                }
                .padding(.bottom, 44)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
}

struct WelcomeStepView: View {
    let onNext: () -> Void
    
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var buttonOpacity: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                // Logo section
                VStack(spacing: 32) {
                    Group {
                        if let uiImage = UIImage(named: "agosec_logo") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: "app.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(
                        width: min(geometry.size.width * 0.4, 160),
                        height: min(geometry.size.width * 0.4, 160)
                    )
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                    .shadow(color: Color.blue.opacity(0.1), radius: 15, x: 0, y: 5)
                    
                    // Welcome message
                    Text("Welcome to Agosec, your AI centered keyboard.")
                        .font(.system(size: min(geometry.size.width * 0.06, 28), weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 32)
                        .opacity(textOpacity)
                }
                .padding(.top, max(geometry.size.height * 0.15, 60))
                
                Spacer()
                
                // Get Started button
                VStack(spacing: 16) {
                    ActionButton(title: "Get Started", action: onNext)
                        .padding(.horizontal, max(geometry.size.width * 0.1, 24))
                        .opacity(buttonOpacity)
                }
                .padding(.bottom, max(geometry.size.height * 0.1, 40))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .onAppear {
            // Animate logo entrance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Animate text entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.5)) {
                    textOpacity = 1.0
                }
            }
            
            // Animate button entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeIn(duration: 0.5)) {
                    buttonOpacity = 1.0
                }
            }
        }
    }
}