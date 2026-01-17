import SwiftUI
import StoreKit
import SharedCore

struct SettingsView: View {
    @EnvironmentObject var entitlementService: EntitlementService
    @State private var showingPaywall = false
    
    var body: some View {
        List {
            subscriptionSection
            
            featuresSection
            
            permissionsSection
            
            supportSection
            
            aboutSection
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingPaywall) {
            PaywallView(router: AppRouter())
        }
    }
    
    private var subscriptionSection: some View {
        Section("Subscription") {
            if entitlementService.entitlementState.isValid {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Active Subscription", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    if let expiresAt = entitlementService.entitlementState.expiresAt {
                        Text("Expires: \(expiresAt, formatter: dateFormatter)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            } else {
                Button(action: { showingPaywall = true }) {
                    Label("Subscribe to Unlock", systemImage: "crown.fill")
                        .foregroundColor(.blue)
                }
            }
            
            Button(action: { Task { await entitlementService.refreshEntitlement() } }) {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
        }
    }
    
    private var featuresSection: some View {
        Section("Features") {
            NavigationLink(destination: KeyboardSettingsView()) {
                Label("Keyboard Settings", systemImage: "keyboard")
            }
            
            NavigationLink(destination: AISettingsView()) {
                Label("AI Assistant", systemImage: "brain")
            }
        }
    }
    
    private var permissionsSection: some View {
        Section("Permissions") {
            Button(action: openKeyboardSettings) {
                HStack {
                    Label("Add Agosec Keyboard", systemImage: "keyboard.badge.ellipsis")
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: openAppSettings) {
                Label("App Permissions", systemImage: "lock.fill")
            }
        }
    }
    
    private var supportSection: some View {
        Section("Support") {
            Button(action: contactSupport) {
                Label("Contact Support", systemImage: "questionmark.circle")
            }
            
            Button(action: openFAQ) {
                Label("FAQ", systemImage: "book")
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.gray)
            }
            
            Button(action: openPrivacyPolicy) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            Button(action: openTerms) {
                Label("Terms of Service", systemImage: "doc.text")
            }
        }
    }
    
    private func openKeyboardSettings() {
        // Open app settings - user will see "Keyboards" option to add Agosec keyboard
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func contactSupport() {
        // TODO: Replace with actual support email or URL
        if let url = URL(string: "mailto:support@agosec.com") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openFAQ() {
        // TODO: Replace with actual FAQ URL
        guard let url = URL(string: "https://agosec.com/faq") else { return }
        UIApplication.shared.open(url)
    }
    
    private func openPrivacyPolicy() {
        // TODO: Replace with actual Privacy Policy URL
        guard let url = URL(string: "https://agosec.com/privacy") else { return }
        UIApplication.shared.open(url)
    }
    
    private func openTerms() {
        // TODO: Replace with actual Terms of Service URL
        guard let url = URL(string: "https://agosec.com/terms") else { return }
        UIApplication.shared.open(url)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

struct KeyboardSettingsView: View {
    @AppStorage("autocorrect_enabled") private var autocorrectEnabled = true
    @AppStorage("predictive_text") private var predictiveText = true
    @AppStorage("caps_lock_enabled") private var capsLockEnabled = true
    
    var body: some View {
        List {
            Section("Typing") {
                Toggle("Auto-Correction", isOn: $autocorrectEnabled)
                Toggle("Predictive Text", isOn: $predictiveText)
                Toggle("Enable Caps Lock", isOn: $capsLockEnabled)
            }
            
            Section("AI Assistant") {
                NavigationLink(destination: AISettingsView()) {
                    Text("AI Settings")
                }
            }
        }
        .navigationTitle("Keyboard Settings")
    }
}

struct AISettingsView: View {
    @AppStorage("ai_suggestions_enabled") private var aiSuggestionsEnabled = true
    @AppStorage("ai_context_enabled") private var aiContextEnabled = true
    @AppStorage("ai_response_length") private var aiResponseLength = "medium"
    
    var body: some View {
        List {
            Section("Features") {
                Toggle("AI Suggestions", isOn: $aiSuggestionsEnabled)
                Toggle("Context from Screenshots", isOn: $aiContextEnabled)
            }
            
            Section("Response Style") {
                Picker("Length", selection: $aiResponseLength) {
                    Text("Short").tag("short")
                    Text("Medium").tag("medium")
                    Text("Long").tag("long")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("AI Assistant")
    }
}