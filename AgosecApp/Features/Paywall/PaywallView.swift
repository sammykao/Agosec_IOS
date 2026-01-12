import SwiftUI
import StoreKit
import SharedCore
import UIComponents

struct PaywallView: View {
    @ObservedObject var router: AppRouter
    @StateObject private var storeKitManager = StoreKitManager()
    @EnvironmentObject var entitlementService: EntitlementService
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                headerSection
                
                featuresSection
                
                Spacer()
                
                subscriptionSection
                
                termsSection
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            storeKitManager.setToastManager(toastManager)
        }
        .onReceive(storeKitManager.$purchaseState) { state in
            if case .success = state {
                toastManager.show("Subscription activated successfully!", type: .success)
                Task {
                    await entitlementService.refreshEntitlement()
                }
            } else if case .failure(let error) = state {
                let message = ErrorMapper.userFriendlyMessage(from: error)
                let shouldRetry = ErrorMapper.shouldShowRetry(for: error)
                toastManager.show(
                    message,
                    type: .error,
                    duration: shouldRetry ? 5.0 : 3.0,
                    retryAction: shouldRetry ? {
                        Task { await storeKitManager.purchase() }
                    } : nil
                )
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Unlock Agosec Keyboard")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Get access to AI-powered typing assistance")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PaywallFeatureRow(
                icon: "keyboard",
                title: "Full Keyboard Access",
                description: "Use Agosec Keyboard in all apps"
            )
            
            PaywallFeatureRow(
                icon: "brain",
                title: "AI Assistant",
                description: "Get smart suggestions and responses"
            )
            
            PaywallFeatureRow(
                icon: "photo",
                title: "Screenshot Context",
                description: "Import screenshots for AI context"
            )
            
            PaywallFeatureRow(
                icon: "infinite",
                title: "Unlimited Usage",
                description: "No limits on AI interactions"
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var subscriptionSection: some View {
        VStack(spacing: 16) {
            if let product = storeKitManager.product {
                VStack(spacing: 8) {
                    Text(product.displayName)
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text(product.displayPrice)
                        .font(.system(size: 32, weight: .bold))
                    
                    Text(product.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                
                ActionButton(
                    title: storeKitManager.isLoading ? "Processing..." : "Subscribe Now",
                    action: { Task { await storeKitManager.purchase() } },
                    isLoading: storeKitManager.isLoading
                )
            } else {
                ProgressView()
                    .onAppear {
                        Task {
                            await storeKitManager.loadProducts()
                        }
                    }
            }
            
            Button("Restore Purchases") {
                Task { await storeKitManager.restorePurchases() }
            }
            .font(.system(size: 14))
            .foregroundColor(.blue)
        }
    }
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Cancel anytime in Settings")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            HStack(spacing: 16) {
                Button("Terms of Service") {
                    openTerms()
                }
                .font(.system(size: 12))
                .foregroundColor(.blue)
                
                Button("Privacy Policy") {
                    openPrivacyPolicy()
                }
                .font(.system(size: 12))
                .foregroundColor(.blue)
            }
        }
    }
    
    private func openTerms() {
        // TODO: Replace with actual Terms of Service URL
        guard let url = URL(string: "https://agosec.com/terms") else { return }
        UIApplication.shared.open(url)
    }
    
    private func openPrivacyPolicy() {
        // TODO: Replace with actual Privacy Policy URL
        guard let url = URL(string: "https://agosec.com/privacy") else { return }
        UIApplication.shared.open(url)
    }
}

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}