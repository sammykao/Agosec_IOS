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
    
    // Animation states
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var glowOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -300
    
    var body: some View {
        ZStack {
            // Dark background
            PaywallBackground()
                .ignoresSafeArea(.all)
            
            // Floating glass orbs
            PaywallFloatingOrbs()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: ResponsiveSystem.isShortScreen ? 24 : 32) {
                    // Header with crown icon
                    PaywallHeader(
                        iconScale: iconScale,
                        iconOpacity: iconOpacity,
                        glowOpacity: glowOpacity,
                        contentOpacity: contentOpacity,
                        contentOffset: contentOffset
                    )
                    
                    // Features section
                    featuresSection
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    // Subscription section
                    subscriptionSection
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    // Terms section
                    PaywallTermsSection(
                        openTerms: openTerms,
                        openPrivacyPolicy: openPrivacyPolicy
                    )
                    .opacity(contentOpacity)
                }
                .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
                .padding(.top, ResponsiveSystem.isShortScreen ? 12 : 16)
                .padding(.bottom, ResponsiveSystem.isShortScreen ? 20 : 24)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            storeKitManager.setToastManager(toastManager)
            startAnimations()
            
            // Immediately refresh entitlement to check if user should have access
            Task { @MainActor in
                await entitlementService.refreshEntitlement()
            }
        }
        .onReceive(storeKitManager.$purchaseState) { state in
            handlePurchaseState(state)
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                PaywallFeatureRow(
                    icon: feature.icon,
                    title: feature.title,
                    description: feature.description,
                    color: feature.color
                )
                .padding(.vertical, ResponsiveSystem.isSmallScreen ? 12 : 14)
                
                if index < features.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.15))
                        .padding(.leading, 60)
                }
            }
        }
        .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 16 : 20)
        .padding(.vertical, ResponsiveSystem.isSmallScreen ? 8 : 12)
        .frame(maxWidth: .infinity)
        .background(
            Color.white.opacity(0.08),
            in: RoundedRectangle(cornerRadius: 24)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var features: [(icon: String, title: String, description: String, color: Color)] {
        [
            ("keyboard.fill", "Full Keyboard Access", "Use Agosec Keyboard in all apps", .blue),
            ("brain.head.profile", "AI Assistant", "Get smart suggestions and responses", .purple),
            ("photo.stack.fill", "Screenshot Context", "Import screenshots for AI context", .green),
            ("infinity", "Unlimited Usage", "No limits on AI interactions", .orange)
        ]
    }
    
    // MARK: - Subscription Section
    
    private var subscriptionSection: some View {
        VStack(alignment: .center, spacing: ResponsiveSystem.isSmallScreen ? 14 : 18) {
            if let product = storeKitManager.product {
                // Price card
                priceCard(product: product)
                
                // Subscribe button
                PaywallSubscribeButton(
                    isLoading: storeKitManager.isLoading,
                    shimmerOffset: shimmerOffset,
                    action: { Task { await storeKitManager.purchase() } }
                )
                
            } else {
                // Loading state
                loadingState
            }
            
            // Restore purchases button
            restorePurchasesButton
        }
        .frame(maxWidth: .infinity)
    }
    
    private func priceCard(product: Product) -> some View {
        VStack(spacing: 8) {
            Text(product.displayName)
                .font(.system(
                    size: ResponsiveSystem.isSmallScreen ? 18 : 20,
                    weight: .semibold,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))
            
            Text(product.displayPrice)
                .font(.system(
                    size: ResponsiveSystem.isSmallScreen ? 36 : 40,
                    weight: .bold,
                    design: .default
                ))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(product.description)
                .font(.system(
                    size: 14,
                    weight: .regular,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
        }
        .padding(.vertical, ResponsiveSystem.isSmallScreen ? 16 : 20)
        .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
        .background(
            Color.white.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.5),
                            Color.purple.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
    
    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            
            Text("Loading subscription...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
        }
        .padding(.vertical, 40)
        .onAppear {
            Task {
                await storeKitManager.loadProducts()
            }
        }
    }
    
    private var restorePurchasesButton: some View {
        Button(action: {
            Task { await storeKitManager.restorePurchases() }
        }) {
            Text("Restore Purchases")
                .font(.system(
                    size: 14,
                    weight: .medium,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .padding(.top, 4)
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        // Icon entrance
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        // Glow pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
        
        // Content entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
        
        // Shimmer animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }
    
    // MARK: - Handlers
    
    private func handlePurchaseState(_ state: StoreKitManager.PurchaseState) {
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
    
    private func openTerms() {
        guard let url = URL(string: "https://agosec.com/terms") else { return }
        UIApplication.shared.open(url)
    }
    
    private func openPrivacyPolicy() {
        guard let url = URL(string: "https://agosec.com/privacy") else { return }
        UIApplication.shared.open(url)
    }
}
