import SwiftUI
import SharedCore

struct LockedView: View {
    let onSubscribeTapped: () -> Void
    
    @State private var isOnboardingComplete: Bool = false
    
    init(onSubscribeTapped: @escaping () -> Void) {
        self.onSubscribeTapped = onSubscribeTapped
        // Check onboarding status
        if let complete: Bool = AppGroupStorage.shared.get(Bool.self, for: "onboarding_complete") {
            _isOnboardingComplete = State(initialValue: complete)
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Keyboard Locked")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                if isOnboardingComplete {
                    Text("Subscribe to Unlock")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Text("Subscribe in the Agosec Keyboard app to unlock AI-powered typing assistance")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                } else {
                    Text("Finish Onboarding")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Text("Complete setup in the Agosec Keyboard app to unlock AI-powered typing assistance")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                ActionButton(
                    title: "Open App to Finish Setup",
                    action: onSubscribeTapped
                )
                
                Text("Or switch keyboards using the globe icon")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}