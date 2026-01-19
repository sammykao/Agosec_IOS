import Foundation
import StoreKit
import SharedCore

/// Checks subscription status directly with Apple's StoreKit 2
/// No backend dependency - queries Apple's transaction history
class StoreKitEntitlementChecker {
    
    private let productId: String
    
    init() {
        self.productId = Config.shared.subscriptionProductId
    }
    
    /// Checks Apple for active subscription and updates local cache
    /// Call this on keyboard load (viewWillAppear)
    func refreshEntitlement() async {
        let entitlement = await checkSubscriptionStatus()
        
        // Save to AppGroupStorage so it's available immediately next time
        AppGroupStorage.shared.set(entitlement, for: "entitlement_state")
        AppGroupStorage.shared.synchronize()
    }
    
    /// Returns cached entitlement (fast, synchronous)
    /// Use this for immediate UI decisions
    func getCachedEntitlement() -> EntitlementState {
        // Check if user is in demo period (onboarding not complete + within time limit)
        if let demoEntitlement = checkDemoPeriod() {
            return demoEntitlement
        }
        
        if let cached: EntitlementState = AppGroupStorage.shared.get(
            EntitlementState.self,
            for: "entitlement_state"
        ) {
            return cached
        }
        
        return EntitlementState(isActive: false)
    }
    
    /// Checks if user is within demo period (48 hours from onboarding start)
    /// Returns valid entitlement if in demo, nil otherwise
    private func checkDemoPeriod() -> EntitlementState? {
        // Check if onboarding is complete - if true, no demo access
        let onboardingComplete: Bool = AppGroupStorage.shared.get(Bool.self, for: "onboarding_complete") ?? false
        
        if onboardingComplete {
            // Onboarding complete - demo period no longer applies
            return nil
        }
        
        // Check if demo period has started
        guard let demoStartDate: Date = AppGroupStorage.shared.get(Date.self, for: "demo_period_start_date") else {
            // Demo hasn't started yet - don't grant access
            return nil
        }
        
        // Demo period: 48 hours from start
        let demoDuration: TimeInterval = 48 * 60 * 60 // 48 hours
        let demoExpiration = demoStartDate.addingTimeInterval(demoDuration)
        
        // Check if demo has expired
        if Date() > demoExpiration {
            // Demo expired - require subscription
            return nil
        }
        
        // Still in demo period
        print("✅ Demo period active - expires: \(demoExpiration)")
        return EntitlementState(
            isActive: true,
            expiresAt: demoExpiration,
            productId: productId
        )
    }
    
    /// Queries Apple's StoreKit 2 for current subscription status
    private func checkSubscriptionStatus() async -> EntitlementState {
        // Check if user is in demo period first
        if let demoEntitlement = checkDemoPeriod() {
            return demoEntitlement
        }
        
        // Iterate through all current entitlements from Apple
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // Check if this is our subscription product
                if transaction.productID == productId {
                    // Check expiration
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            // Active subscription
                            return EntitlementState(
                                isActive: true,
                                expiresAt: expirationDate,
                                productId: transaction.productID
                            )
                        }
                        // Expired
                    } else {
                        // No expiration = lifetime purchase (unlikely for subscription)
                        return EntitlementState(
                            isActive: true,
                            expiresAt: nil,
                            productId: transaction.productID
                        )
                    }
                }
                
            case .unverified(_, let verificationError):
                // Transaction failed verification - don't trust it
                print("⚠️ Unverified transaction: \(verificationError)")
                continue
            }
        }
        
        // No valid subscription found
        return EntitlementState(isActive: false)
    }
}
