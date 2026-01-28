import SwiftUI

struct AgentIntroDeleteConfirmationOverlay: View {
    let onUseAndDelete: () -> Void
    let onUseOnly: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Delete Screenshots?")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))

                Text("Would you like to delete the screenshots from Photos after importing?")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Button(action: onUseAndDelete) {
                        Text("Use & Delete")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(10)
                    }

                    Button(action: onUseOnly) {
                        Text("Use Only")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                    }

                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 320)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
    }
}

struct AgentIntroPhotoAccessOverlay: View {
    let onOpenSettings: () -> Void
    let onSkip: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Photo Access Required")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))

                Text("Photo access is required to import screenshots. You can enable it in Settings or skip this step.")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Button(action: onOpenSettings) {
                        Text("Open Settings")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .cornerRadius(10)
                    }

                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 320)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
    }
}
