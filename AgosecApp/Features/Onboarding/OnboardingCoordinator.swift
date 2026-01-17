import SwiftUI
import UIKit
import SharedCore
import UIComponents

struct OnboardingCoordinator: View {
    @ObservedObject var router: AppRouter
    @State private var currentStep: OnboardingStep = .welcome
    @State private var transitionOffset: CGFloat = 0
    
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
            // Background gradient with subtle animation
            animatedBackground
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Main content area with smooth transitions
            Group {
                switch currentStep {
                case .welcome:
                    WelcomeStepView(onNext: { navigateToNext() })
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                case .enableKeyboard:
                    EnableKeyboardStepView(onNext: { navigateToNext() })
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                case .enableFullAccess:
                    EnableFullAccessStepView(onNext: { navigateToNext() })
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                case .photosPermission:
                    PhotosPermissionStepView(onNext: { navigateToNext() })
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                case .demo:
                    DemoConversationStepView(onComplete: {
                        AppGroupStorage.shared.set(true, for: "onboarding_complete")
                        router.navigateTo(.paywall)
                    })
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
            
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
        .onAppear {
            // Animate background gradient
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                transitionOffset = 0.1
            }
        }
    }
    
    private var animatedBackground: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.08),
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.06, green: 0.06, blue: 0.1)
                ]),
                startPoint: UnitPoint(x: 0.5 + transitionOffset, y: 0),
                endPoint: UnitPoint(x: 0.5 - transitionOffset, y: 1)
            )
            
            // Subtle floating accent
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.15),
                    Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.08),
                    Color.clear
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
        }
    }
    
    private func navigateToNext() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
            }
        }
    }
}
