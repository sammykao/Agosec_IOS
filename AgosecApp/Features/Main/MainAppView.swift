import SwiftUI
import SharedCore

struct MainAppView: View {
    @ObservedObject var router: AppRouter
    @EnvironmentObject var entitlementService: EntitlementService
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.97, green: 0.97, blue: 0.99)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Agosec Keyboard")
                            .font(.system(size: 28, weight: .bold))
                        Spacer()
                        subscriptionButton
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Status Section
                    statusSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Settings Button
                    Button(action: { showingSettings = true }) {
                        HStack {
                            Image(systemName: "gear")
                                .font(.system(size: 20))
                            Text("Settings")
                                .font(.system(size: 18, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView()
            }
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status")
                .font(.system(size: 20, weight: .bold))
            
            VStack(spacing: 12) {
                StatusRow(
                    icon: "keyboard",
                    title: "Keyboard",
                    status: permissionsService.isKeyboardExtensionEnabled ? "Enabled" : "Not Enabled",
                    isActive: permissionsService.isKeyboardExtensionEnabled
                )
                
                StatusRow(
                    icon: "lock.fill",
                    title: "Full Access",
                    status: permissionsService.hasFullAccess ? "Granted" : "Not Granted",
                    isActive: permissionsService.hasFullAccess
                )
                
                StatusRow(
                    icon: "crown.fill",
                    title: "Subscription",
                    status: subscriptionStatusText,
                    isActive: entitlementService.entitlementState.isValid
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionCard(
                    icon: "brain",
                    title: "Try Agent Mode",
                    description: "Open keyboard and tap the brain icon",
                    color: .purple
                )
                
                QuickActionCard(
                    icon: "photo",
                    title: "Import Screenshots",
                    description: "Use screenshots for AI context",
                    color: .blue
                )
                
                QuickActionCard(
                    icon: "keyboard",
                    title: "Keyboard Settings",
                    description: "Customize your keyboard",
                    color: .orange
                )
                
                QuickActionCard(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    description: "Get help using the keyboard",
                    color: .green
                )
            }
        }
    }
    
    private var subscriptionButton: some View {
        Button("Manage Subscription") {
            router.navigateTo(.paywall)
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
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .green : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Text(status)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .green : .gray)
            }
            
            Spacer()
            
            Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isActive ? .green : .gray)
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

