import SwiftUI
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
