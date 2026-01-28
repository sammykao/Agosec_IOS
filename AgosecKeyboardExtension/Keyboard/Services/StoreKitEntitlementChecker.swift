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
        // Check demo period first - if active, don't overwrite it with StoreKit check
        if let demoEntitlement = EntitlementEvaluator.demoEntitlement(
            requiresOnboardingIncomplete: true
        ) {
            // Demo period is active - save it to cache
            EntitlementEvaluator.saveEntitlement(demoEntitlement)
            return
        }

        // No demo period - check StoreKit for real subscription
        let entitlement = await checkSubscriptionStatus()

        // Save to AppGroupStorage so it's available immediately next time
        EntitlementEvaluator.saveEntitlement(entitlement)
    }

    /// Returns cached entitlement (fast, synchronous)
    /// Use this for immediate UI decisions
    func getCachedEntitlement() -> EntitlementState {
        // Check if user is in demo period (onboarding not complete + within time limit)
        if let demoEntitlement = EntitlementEvaluator.demoEntitlement(
            requiresOnboardingIncomplete: true
        ) {
            return demoEntitlement
        }

        if let cached = EntitlementEvaluator.cachedEntitlement() {
            return cached
        }

        return EntitlementState(isActive: false)
    }

    /// Queries Apple's StoreKit 2 for current subscription status
    private func checkSubscriptionStatus() async -> EntitlementState {
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

            case .unverified:
                // Transaction failed verification - don't trust it
                continue
            }
        }

        // No valid subscription found
        return EntitlementState(isActive: false)
    }
}
