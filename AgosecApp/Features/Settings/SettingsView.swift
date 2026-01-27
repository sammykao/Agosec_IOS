import SwiftUI
import StoreKit
import SharedCore
import UIComponents
import UIKit

struct SettingsView: View {
    @EnvironmentObject var entitlementService: EntitlementService
    @Environment(\.dismiss) private var dismiss
    @State private var showingPaywall = false

    var body: some View {
        ZStack {
            SettingsBackground()
                .ignoresSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: ResponsiveSystem.isSmallScreen ? 14 : 18) {
                    SettingsHeader(
                        title: "Settings",
                        icon: "xmark",
                        action: { dismiss() }
                    )

                    subscriptionCard
                    preferencesCard
                    supportCard
                    aboutCard
                }
                .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
                .padding(.top, ResponsiveSystem.isShortScreen ? 14 : 20)
                .padding(.bottom, ResponsiveSystem.isShortScreen ? 24 : 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingPaywall) {
            PaywallView(router: AppRouter())
        }
    }

    private var subscriptionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SettingsSectionTitle(text: "Subscription")

                if entitlementService.entitlementState.isValid {
                    SettingsInfoRow(
                        icon: "checkmark.seal.fill",
                        title: "Active",
                        subtitle: subscriptionStatusText,
                        accent: .green
                    )
                } else {
                    SettingsRowButton(
                        icon: "crown.fill",
                        title: "Unlock Premium",
                        subtitle: "Full AI access and unlimited usage",
                        action: { showingPaywall = true }
                    )
                }

                SettingsRowButton(
                    icon: "arrow.clockwise",
                    title: "Restore Purchases",
                    subtitle: "Sync your subscription",
                    action: { Task { await entitlementService.refreshEntitlement() } }
                )
            }
        }
    }

    private var preferencesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SettingsSectionTitle(text: "Preferences")

                NavigationLink(destination: KeyboardSettingsView()) {
                    SettingsRowLabel(
                        icon: "keyboard",
                        title: "Keyboard Settings",
                        subtitle: "Typing and layout"
                    )
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: AISettingsView()) {
                    SettingsRowLabel(
                        icon: "brain.head.profile",
                        title: "AI Assistant",
                        subtitle: "Response style and context"
                    )
                }
                .buttonStyle(PlainButtonStyle())

                SettingsRowButton(
                    icon: "keyboard.badge.ellipsis",
                    title: "Add Agosec Keyboard",
                    subtitle: "Open iOS keyboard settings",
                    action: openKeyboardSettings
                )

                SettingsRowButton(
                    icon: "lock.fill",
                    title: "App Permissions",
                    subtitle: "Manage access and privacy",
                    action: openAppSettings
                )
            }
        }
    }

    private var supportCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SettingsSectionTitle(text: "Support")

                SettingsRowButton(
                    icon: "questionmark.circle",
                    title: "Contact Support",
                    subtitle: "Get help fast",
                    action: contactSupport
                )

                SettingsRowButton(
                    icon: "book",
                    title: "FAQ",
                    subtitle: "Common questions",
                    action: openFAQ
                )
            }
        }
    }

    private var aboutCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SettingsSectionTitle(text: "Legal")
                
                SettingsRowButton(
                    icon: "hand.raised",
                    title: "Privacy Policy",
                    subtitle: "How we handle your data",
                    action: openPrivacyPolicy
                )
                
                SettingsRowButton(
                    icon: "doc.text",
                    title: "Terms of Service",
                    subtitle: "Usage and subscription terms",
                    action: openTerms
                )
                
                NavigationLink(destination: LogViewer()) {
                    SettingsRowLabel(
                        icon: "doc.text.magnifyingglass",
                        title: "View Logs",
                        subtitle: "Debug keyboard extension logs"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: DebugStatusView()) {
                    SettingsRowLabel(
                        icon: "ladybug",
                        title: "Debug Status",
                        subtitle: "Check last log entries"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                SettingsValueRow(
                    icon: "number",
                    title: "Version",
                    value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                )
            }
        }
    }

    private var subscriptionStatusText: String {
        if let expiresAt = entitlementService.entitlementState.expiresAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Active until \(formatter.string(from: expiresAt))"
        }
        return "Active"
    }

    private func openKeyboardSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func contactSupport() {
        if let url = URL(string: "mailto:support@agosec.com") {
            UIApplication.shared.open(url)
        }
    }

    private func openFAQ() {
        guard let url = URL(string: "https://agosec.com/faq") else { return }
        UIApplication.shared.open(url)
    }

    private func openPrivacyPolicy() {
        guard let url = URL(string: "https://agosec.com/privacy") else { return }
        UIApplication.shared.open(url)
    }

    private func openTerms() {
        guard let url = URL(string: "https://agosec.com/terms") else { return }
        UIApplication.shared.open(url)
    }
}

struct KeyboardSettingsView: View {
    @AppStorage("autocorrect_enabled") private var autocorrectEnabled = true
    @AppStorage("predictive_text") private var predictiveText = true
    @AppStorage("caps_lock_enabled") private var capsLockEnabled = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SettingsBackground()
                .ignoresSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: ResponsiveSystem.isSmallScreen ? 14 : 18) {
                    SettingsHeader(
                        title: "Keyboard",
                        icon: "chevron.left",
                        action: { dismiss() }
                    )

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionTitle(text: "Typing")

                            SettingsToggleRow(title: "Auto-Correction", isOn: $autocorrectEnabled)
                            SettingsToggleRow(title: "Predictive Text", isOn: $predictiveText)
                            SettingsToggleRow(title: "Enable Caps Lock", isOn: $capsLockEnabled)
                        }
                    }

                    NavigationLink(destination: AISettingsView()) {
                        SettingsRowLabel(
                            icon: "brain.head.profile",
                            title: "AI Assistant",
                            subtitle: "Response and context settings"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
                .padding(.top, ResponsiveSystem.isShortScreen ? 14 : 20)
                .padding(.bottom, ResponsiveSystem.isShortScreen ? 24 : 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarHidden(true)
    }
}

struct AISettingsView: View {
    @AppStorage("ai_suggestions_enabled") private var aiSuggestionsEnabled = true
    @AppStorage("ai_context_enabled") private var aiContextEnabled = true
    @AppStorage("ai_response_length") private var aiResponseLength = "medium"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SettingsBackground()
                .ignoresSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: ResponsiveSystem.isSmallScreen ? 14 : 18) {
                    SettingsHeader(
                        title: "AI Assistant",
                        icon: "chevron.left",
                        action: { dismiss() }
                    )

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionTitle(text: "Features")

                            SettingsToggleRow(title: "AI Suggestions", isOn: $aiSuggestionsEnabled)
                            SettingsToggleRow(title: "Context from Screenshots", isOn: $aiContextEnabled)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionTitle(text: "Response Style")

                            Picker("Length", selection: $aiResponseLength) {
                                Text("Short").tag("short")
                                Text("Medium").tag("medium")
                                Text("Long").tag("long")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .accentColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                        }
                    }
                }
                .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
                .padding(.top, ResponsiveSystem.isShortScreen ? 14 : 20)
                .padding(.bottom, ResponsiveSystem.isShortScreen ? 24 : 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarHidden(true)
    }
}

struct SettingsHeader: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.12), in: Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.98))

            Spacer()
        }
    }
}

struct SettingsSectionTitle: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
            .tracking(1.2)
    }
}

struct SettingsRowLabel: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            SettingsIcon(icon: icon)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct SettingsRowButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                SettingsIcon(icon: icon)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .padding(12)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            SettingsIcon(icon: icon, accent: accent)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct SettingsValueRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            SettingsIcon(icon: icon)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
        }
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.0, green: 0.48, blue: 1.0)))
        }
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct SettingsIcon: View {
    let icon: String
    var accent: Color = Color(red: 0.0, green: 0.48, blue: 1.0)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.25), accent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 34, height: 34)

            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(accent)
        }
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color.white.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 22)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 22, x: 0, y: 12)
    }
}

struct SettingsBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.08),
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.06, green: 0.06, blue: 0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            SettingsFloatingOrbs()
        }
    }
}

struct SettingsFloatingOrbs: View {
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.18 - Double(index) * 0.05),
                                Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.14 - Double(index) * 0.04),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 120 + CGFloat(index) * 60
                        )
                    )
                    .frame(width: 220 + CGFloat(index) * 90, height: 220 + CGFloat(index) * 90)
                    .blur(radius: 50)
                    .offset(
                        x: CGFloat(index) * 70 - 120,
                        y: CGFloat(index) * 90 - 180
                    )
                    .opacity(0.65)
            }
        }
    }
}
