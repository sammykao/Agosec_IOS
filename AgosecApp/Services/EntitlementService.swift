import Foundation
import Combine
import StoreKit
import SharedCore
import Networking

/// Manages entitlement state by checking demo period, mock backend, or Apple StoreKit
class EntitlementService: ObservableObject {
    @Published var entitlementState: EntitlementState = EntitlementState(isActive: false)
    
    private let productId = Config.shared.subscriptionProductId
    private var timer: Timer?
    
    init() {
        loadEntitlement()
        
        // Check entitlement on init
        Task {
            await refreshEntitlement()
        }
        
        startPeriodicRefresh()
    }
    
    /// Load cached entitlement from AppGroupStorage (fast, synchronous)
    func loadEntitlement() {
        // Check demo period first (fast, synchronous check)
        if let demoEntitlement = EntitlementEvaluator.demoEntitlement(
            requiresOnboardingIncomplete: false
        ) {
            entitlementState = demoEntitlement
            return
        }
        
        // Fall back to cached entitlement
        if let stored = EntitlementEvaluator.cachedEntitlement() {
            entitlementState = stored
        }
    }
    
    /// Refresh entitlement by checking demo period, mock backend, or StoreKit
    @MainActor
    func refreshEntitlement() async {
        // Priority 1: Check demo period first - if active, don't overwrite it
        if let demoEntitlement = EntitlementEvaluator.demoEntitlement(
            requiresOnboardingIncomplete: false
        ) {
            entitlementState = demoEntitlement
            EntitlementEvaluator.saveEntitlement(demoEntitlement)
            return
        }
        
        // Priority 2: In mock backend mode, use MockEntitlementAPI
        if BuildMode.isMockBackend {
            do {
                let mockAPI = ServiceFactory.createEntitlementAPI(
                    baseURL: Config.shared.backendBaseUrl,
                    accessToken: nil
                )
                let mockEntitlement = try await mockAPI.fetchEntitlement()
                entitlementState = mockEntitlement
                EntitlementEvaluator.saveEntitlement(mockEntitlement)
                return
            } catch {
                // Fall through to StoreKit check
            }
        }
        
        // Priority 3: Check StoreKit for real subscription
        let storeKitEntitlement = await checkStoreKitSubscription()
        entitlementState = storeKitEntitlement
        EntitlementEvaluator.saveEntitlement(storeKitEntitlement)
    }
    
    /// Queries Apple's StoreKit 2 for current subscription status
    private func checkStoreKitSubscription() async -> EntitlementState {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productId {
                    if let expirationDate = transaction.expirationDate, expirationDate > Date() {
                        // Active subscription found
                        return EntitlementState(
                            isActive: true,
                            expiresAt: expirationDate,
                            productId: transaction.productID
                        )
                    }
                }
            }
        }
        
        // No valid subscription found
        return EntitlementState(isActive: false)
    }
    
    private func startPeriodicRefresh() {
        // Refresh every hour to catch subscription renewals/expirations
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            Task { @MainActor in
                await self.refreshEntitlement()
            }
        }
    }
}
