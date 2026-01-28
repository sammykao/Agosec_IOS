import SwiftUI
import SharedCore
import UIComponents

struct MainAppView: View {
    @ObservedObject var router: AppRouter
    @EnvironmentObject var entitlementService: EntitlementService
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            darkBackground
                .ignoresSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: ResponsiveSystem.isSmallScreen ? 16 : 20) {
                    headerSection
                    statusSection
                    actionsSection
                }
                .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
                .padding(.top, ResponsiveSystem.isShortScreen ? 16 : 24)
                .padding(.bottom, ResponsiveSystem.isShortScreen ? 24 : 32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView()
            }
        }
        .onAppear {
            permissionsService.refreshStatus()
        }
        .onAppBecameActive {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                permissionsService.refreshStatus()
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Agosec")
                    .font(.system(size: ResponsiveSystem.isSmallScreen ? 30 : 34, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 0.0, green: 0.48, blue: 1.0),
                                Color(red: 0.58, green: 0.0, blue: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("A sleek, secure AI keyboard experience.")
                    .font(.system(size: ResponsiveSystem.isSmallScreen ? 14 : 15, weight: .regular))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
            }

            Spacer()

            GlassPillButton(
                title: entitlementService.entitlementState.isValid ? "Manage" : "Upgrade",
                icon: "crown.fill",
                action: { router.navigateTo(.paywall) }
            )
        }
    }

    private var statusSection: some View {
        MainGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Status")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

                StatusRow(
                    icon: "keyboard",
                    title: "Keyboard",
                    status: permissionsService.isKeyboardEnabled ? "Enabled" : "Not Enabled",
                    isActive: permissionsService.isKeyboardEnabled
                )

                StatusRow(
                    icon: "lock.fill",
                    title: "Full Access",
                    status: permissionsService.hasFullAccessState ? "Granted" : "Not Granted",
                    isActive: permissionsService.hasFullAccessState
                )

                StatusRow(
                    icon: "sparkles",
                    title: "Agent Mode",
                    status: "Tap the brain icon in your keyboard",
                    isActive: true
                )

                StatusRow(
                    icon: "crown.fill",
                    title: "Subscription",
                    status: subscriptionStatusText,
                    isActive: entitlementService.entitlementState.isValid
                )
            }
        }
    }

    private var actionsSection: some View {
        MainGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Quick Actions")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

                GlassActionButton(
                    title: "Open Settings",
                    icon: "gearshape.fill",
                    style: .secondary,
                    action: { showingSettings = true }
                )

                GlassActionButton(
                    title: entitlementService.entitlementState.isValid ? "Manage Subscription" : "Unlock Premium",
                    icon: "crown.fill",
                    style: .primary,
                    action: { router.navigateTo(.paywall) }
                )
            }
        }
    }

    private var subscriptionStatusText: String {
        if entitlementService.entitlementState.isValid {
            if let expiresAt = entitlementService.entitlementState.expiresAt {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Active until \(formatter.string(from: expiresAt))"
            }
            return "Active"
        }
        return "Not Subscribed"
    }

    private var darkBackground: some View {
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

            MainFloatingOrbs()
        }
    }
}

struct StatusRow: View {
    let icon: String
    let title: String
    let status: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                (isActive ? Color.green : Color.gray).opacity(0.25),
                                (isActive ? Color.green : Color.gray).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isActive ? Color.green : Color.gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

                Text(status)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
            }

            Spacer()

            Circle()
                .fill(isActive ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
    }
}

struct MainGlassCard<Content: View>: View {
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

struct GlassPillButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.48, blue: 1.0),
                        Color(red: 0.58, green: 0.0, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Color.blue.opacity(0.35), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GlassActionButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let icon: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(style == .primary ? .white : Color(red: 0.9, green: 0.9, blue: 0.95))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundStyle, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(style == .primary ? 0.2 : 0.25), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.48, blue: 1.0),
                        Color(red: 0.58, green: 0.0, blue: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .secondary:
            return AnyShapeStyle(Color.white.opacity(0.12))
        }
    }
}

struct MainFloatingOrbs: View {
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
                        y: CGFloat(index) * 90 - 160
                    )
                    .opacity(0.65)
            }
        }
    }
}
