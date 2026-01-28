import Foundation
import SharedCore

final class KeyboardEntitlementCoordinator {
    private let checker: StoreKitEntitlementChecker

    init(checker: StoreKitEntitlementChecker = StoreKitEntitlementChecker()) {
        self.checker = checker
    }

    func cachedEntitlement() -> EntitlementState {
        checker.getCachedEntitlement()
    }

    func refreshEntitlement() async -> EntitlementState {
        await checker.refreshEntitlement()
        return checker.getCachedEntitlement()
    }
}
