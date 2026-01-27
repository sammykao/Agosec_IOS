import Foundation

public enum EntitlementEvaluator {
    private static let demoDuration: TimeInterval = 48 * 60 * 60

    public static func demoEntitlement(
        storage: AppGroupStorage = .shared,
        now: Date = Date(),
        productId: String = Config.shared.subscriptionProductId,
        requiresOnboardingIncomplete: Bool
    ) -> EntitlementState? {
        if requiresOnboardingIncomplete {
            let onboardingComplete: Bool = storage.get(Bool.self, for: AppGroupKeys.onboardingComplete) ?? false
            if onboardingComplete {
                return nil
            }
        }

        guard let demoStartDate: Date = storage.get(Date.self, for: AppGroupKeys.demoPeriodStartDate) else {
            return nil
        }

        let demoExpiration = demoStartDate.addingTimeInterval(demoDuration)
        if now > demoExpiration {
            return nil
        }

        return EntitlementState(
            isActive: true,
            expiresAt: demoExpiration,
            productId: productId
        )
    }

    public static func cachedEntitlement(storage: AppGroupStorage = .shared) -> EntitlementState? {
        storage.get(EntitlementState.self, for: AppGroupKeys.entitlementState)
    }

    public static func saveEntitlement(_ entitlement: EntitlementState, storage: AppGroupStorage = .shared) {
        storage.set(entitlement, for: AppGroupKeys.entitlementState)
        storage.synchronize()
    }
}
