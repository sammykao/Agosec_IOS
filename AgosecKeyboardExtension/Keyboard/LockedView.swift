import SwiftUI
import UIKit
import SharedCore

struct LockedView: View {
    let onSubscribeTapped: () -> Void
    
    @State private var isOnboardingComplete: Bool = false
    @State private var hasDemoStarted: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    init(onSubscribeTapped: @escaping () -> Void) {
        self.onSubscribeTapped = onSubscribeTapped
        if let complete: Bool = AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.onboardingComplete) {
            _isOnboardingComplete = State(initialValue: complete)
        }
        if let _: Date = AppGroupStorage.shared.get(Date.self, for: AppGroupKeys.demoPeriodStartDate) {
            _hasDemoStarted = State(initialValue: true)
        }
    }
    
    private var shouldShowSubscribeMessage: Bool {
        // Show subscribe message if:
        // 1. Onboarding is complete, OR
        // 2. Demo period has started (user is in demo step)
        return isOnboardingComplete || hasDemoStarted
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Content area - centered
            VStack(spacing: 16) {
                // Icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.orange)
                    .padding(.bottom, 8)
                
                // Title
                Text(shouldShowSubscribeMessage ? "Subscribe to Unlock" : "Finish Setup")
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(primaryTextColor)
                
                // Subtitle
                Text(shouldShowSubscribeMessage
                     ? "Subscribe to use AI features"
                     : "Complete setup to continue")
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Button area - fixed at bottom
            VStack(spacing: 12) {
                Button(action: {
                    UIImpactFeedbackGenerator.safeImpact(.medium)
                    onSubscribeTapped()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 15, weight: .medium))
                        Text("Open Agosec App")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 24)
                
                Text(AccessCopy.lockedViewFooter)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(tertiaryTextColor)
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    // MARK: - Colors
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark 
            ? Color(white: 0.7)
            : Color(white: 0.4)
    }
    
    private var tertiaryTextColor: Color {
        colorScheme == .dark
            ? Color(white: 0.5)
            : Color(white: 0.5)
    }
}
