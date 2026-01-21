import SwiftUI
import UIKit

struct FullAccessRequiredView: View {
    let onOpenSettings: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Content area
            VStack(spacing: 16) {
                Image(systemName: "keyboard.badge.exclamationmark")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.orange)
                    .padding(.bottom, 8)
                
                Text("Full Access Required")
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(primaryTextColor)
                
                Text("Enable Full Access in Settings to use this keyboard")
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Button area
            VStack(spacing: 12) {
                Button(action: {
                    UIImpactFeedbackGenerator.safeImpact(.medium)
                    onOpenSettings()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "gear")
                            .font(.system(size: 15, weight: .medium))
                        Text("Open Settings")
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
                
                Text("Settings → Keyboards → Agosec → Full Access")
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
