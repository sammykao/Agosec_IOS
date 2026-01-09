import SwiftUI

struct OnboardingCoordinator: View {
    @ObservedObject var router: AppRouter
    @State private var currentStep: OnboardingStep = .welcome
    
    enum OnboardingStep {
        case welcome
        case enableKeyboard
        case enableFullAccess
        case photosPermission
        case demo
    }
    
    var body: some View {
        NavigationView {
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
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct WelcomeStepView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "keyboard.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to Agosec Keyboard")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "keyboard",
                    title: "Smart Typing",
                    description: "Full-featured keyboard with AI assistance"
                )
                
                FeatureRow(
                    icon: "photo",
                    title: "Screenshot Context",
                    description: "Import screenshots for AI context (optional)"
                )
                
                FeatureRow(
                    icon: "lock.fill",
                    title: "Privacy First",
                    description: "Your data stays on your device"
                )
            }
            
            Spacer()
            
            ActionButton(title: "Get Started", action: onNext)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}