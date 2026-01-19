import SwiftUI

struct FullAccessRequiredView: View {
    let onOpenSettings: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Content area
                VStack(spacing: 12) {
                    Image(systemName: "keyboard.badge.exclamationmark")
                        .font(.system(size: 36))
                        .foregroundColor(.orange)
                    
                    Text("Full Access Required")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                    
                    Text("Enable Full Access in Settings to use this keyboard")
                        .font(.system(size: 14))
                        .foregroundColor(secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * 0.6)
                
                // Button area
                VStack(spacing: 8) {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        onOpenSettings()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "gear")
                                .font(.system(size: 14, weight: .medium))
                            Text("Open Settings")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                    
                    Text("Settings → Keyboards → Agosec → Full Access")
                        .font(.system(size: 11))
                        .foregroundColor(tertiaryTextColor)
                }
                .frame(height: geometry.size.height * 0.35)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
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
