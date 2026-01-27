import SwiftUI
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
            // Background gradient with subtle animation
            GlassmorphicBackground()
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
                        AppGroupStorage.shared.set(true, for: AppGroupKeys.onboardingComplete)
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
            if AppGroupStorage.shared.get(Date.self, for: AppGroupKeys.demoPeriodStartDate) == nil {
                AppGroupStorage.shared.set(Date(), for: AppGroupKeys.demoPeriodStartDate)
                AppGroupStorage.shared.synchronize()
            }
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
