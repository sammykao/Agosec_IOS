import Foundation
import Combine
import StoreKit
import SharedCore

/// Manages entitlement state by checking Apple StoreKit directly
/// No backend dependency for subscription status - queries Apple's transaction history
class EntitlementService: ObservableObject {
    @Published var entitlementState: EntitlementState = EntitlementState(isActive: false)
    
    private let productId = Config.shared.subscriptionProductId
    private var timer: Timer?
    
    init() {
        loadEntitlement()
        
        // Check Apple on init
        Task {
            await refreshEntitlement()
        }
        
        startPeriodicRefresh()
    }
    
    /// Load cached entitlement from AppGroupStorage (fast, synchronous)
    func loadEntitlement() {
        if let stored: EntitlementState = AppGroupStorage.shared.get(EntitlementState.self, for: "entitlement_state") {
            entitlementState = stored
        }
    }
    
    /// Query Apple StoreKit directly for current subscription status
    @MainActor
    func refreshEntitlement() async {
        var foundActiveSubscription = false
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productId {
                    if let expirationDate = transaction.expirationDate, expirationDate > Date() {
                        // Active subscription found
                        let entitlement = EntitlementState(
                            isActive: true,
                            expiresAt: expirationDate,
                            productId: transaction.productID
                        )
                        entitlementState = entitlement
                        AppGroupStorage.shared.set(entitlement, for: "entitlement_state")
                        AppGroupStorage.shared.synchronize()
                        foundActiveSubscription = true
                        break
                    }
                }
            }
        }
        
        // No active subscription - update state
        if !foundActiveSubscription {
            let expiredEntitlement = EntitlementState(isActive: false)
            entitlementState = expiredEntitlement
            AppGroupStorage.shared.set(expiredEntitlement, for: "entitlement_state")
            AppGroupStorage.shared.synchronize()
        }
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