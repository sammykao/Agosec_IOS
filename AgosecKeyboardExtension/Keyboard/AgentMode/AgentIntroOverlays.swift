import SwiftUI

struct AgentIntroDeleteConfirmationOverlay: View {
    let onUseAndDelete: () -> Void
    let onUseOnly: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Delete Screenshots?")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(AgentIntroTheme.textPrimary)

                VStack(spacing: 8) {
                    Button(action: onUseAndDelete) {
                        Text("Use & Delete")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.red,
                                        Color.red.opacity(0.85)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }

                    Button(action: onUseOnly) {
                        Text("Use Only")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(AgentIntroTheme.accentBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AgentIntroTheme.glassFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AgentIntroTheme.glassBorder, lineWidth: 1)
                            )
                            .cornerRadius(12)
                    }

                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(AgentIntroTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AgentIntroTheme.glassFill)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AgentIntroTheme.accentBlue.opacity(0.2),
                                        AgentIntroTheme.accentPurple.opacity(0.15),
                                        AgentIntroTheme.glassFill
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AgentIntroTheme.cardBorder, lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
        }
    }
}

struct AgentIntroPhotoAccessOverlay: View {
    let onOpenSettings: () -> Void
    let onSkip: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Photo Access Required")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(AgentIntroTheme.textPrimary)

                Text("Photo access is required to import screenshots. You can enable it in Settings or skip this step.")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(AgentIntroTheme.textSecondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Button(action: onOpenSettings) {
                        Text("Open Settings")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [
                                        AgentIntroTheme.accentBlue,
                                        AgentIntroTheme.accentBlue.opacity(0.85)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }

                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(AgentIntroTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AgentIntroTheme.glassFill)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AgentIntroTheme.accentBlue.opacity(0.2),
                                        AgentIntroTheme.accentPurple.opacity(0.15),
                                        AgentIntroTheme.glassFill
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AgentIntroTheme.cardBorder, lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
        }
    }
}
