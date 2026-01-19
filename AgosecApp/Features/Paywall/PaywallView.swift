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
        GeometryReader { geometry in
            ZStack {
                // Dark background
                PaywallBackground()
                    .ignoresSafeArea(.all)
                
                // Floating glass orbs
                PaywallFloatingOrbs(geometry: geometry)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: max(geometry.size.height * 0.06, 40))
                        
                        // Header with crown icon
                        PaywallHeader(
                            geometry: geometry,
                            iconScale: iconScale,
                            iconOpacity: iconOpacity,
                            glowOpacity: glowOpacity,
                            contentOpacity: contentOpacity,
                            contentOffset: contentOffset
                        )
                        
                        // Features section
                        featuresSection(in: geometry)
                            .padding(.top, min(geometry.size.height * 0.03, 24))
                        
                        // Subscription section
                        subscriptionSection(in: geometry)
                            .padding(.top, min(geometry.size.height * 0.03, 24))
                        
                        // Terms section
                        PaywallTermsSection(
                            geometry: geometry,
                            openTerms: openTerms,
                            openPrivacyPolicy: openPrivacyPolicy
                        )
                        .padding(.top, min(geometry.size.height * 0.02, 16))
                        .padding(.bottom, 40)
                        .opacity(contentOpacity)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            storeKitManager.setToastManager(toastManager)
            startAnimations()
        }
        .onReceive(storeKitManager.$purchaseState) { state in
            handlePurchaseState(state)
        }
    }
    
    // MARK: - Features Section
    
    private func featuresSection(in geometry: GeometryProxy) -> some View {
        let isSmallScreen = geometry.size.width < 380
        
        return VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                PaywallFeatureRow(
                    icon: feature.icon,
                    title: feature.title,
                    description: feature.description,
                    color: feature.color,
                    geometry: geometry
                )
                .padding(.vertical, isSmallScreen ? 12 : 14)
                
                if index < features.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.15))
                        .padding(.leading, min(geometry.size.width * 0.15, 60))
                }
            }
        }
        .padding(.horizontal, isSmallScreen ? 16 : 20)
        .padding(.vertical, isSmallScreen ? 8 : 12)
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
        .padding(.horizontal, geometry.size.width * 0.06)
        .opacity(contentOpacity)
        .offset(y: contentOffset)
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
    
    private func subscriptionSection(in geometry: GeometryProxy) -> some View {
        let isSmallScreen = geometry.size.width < 380
        
        return VStack(spacing: isSmallScreen ? 14 : 18) {
            if let product = storeKitManager.product {
                // Price card
                priceCard(product: product, in: geometry)
                
                // Subscribe button
                PaywallSubscribeButton(
                    geometry: geometry,
                    isLoading: storeKitManager.isLoading,
                    shimmerOffset: shimmerOffset,
                    action: { Task { await storeKitManager.purchase() } }
                )
                
            } else {
                // Loading state
                loadingState
            }
            
            // Restore purchases button
            restorePurchasesButton(in: geometry)
        }
        .padding(.horizontal, geometry.size.width * 0.06)
        .opacity(contentOpacity)
        .offset(y: contentOffset)
    }
    
    private func priceCard(product: Product, in geometry: GeometryProxy) -> some View {
        let isSmallScreen = geometry.size.width < 380
        
        return VStack(spacing: 8) {
            Text(product.displayName)
                .font(.system(
                    size: min(geometry.size.width * 0.05, 20),
                    weight: .semibold,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))
            
            Text(product.displayPrice)
                .font(.system(
                    size: min(geometry.size.width * 0.1, 40),
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
                    size: min(geometry.size.width * 0.035, 14),
                    weight: .regular,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
        }
        .padding(.vertical, isSmallScreen ? 16 : 20)
        .padding(.horizontal, isSmallScreen ? 20 : 24)
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
    
    private func restorePurchasesButton(in geometry: GeometryProxy) -> some View {
        Button(action: {
            Task { await storeKitManager.restorePurchases() }
        }) {
            Text("Restore Purchases")
                .font(.system(
                    size: min(geometry.size.width * 0.035, 14),
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
