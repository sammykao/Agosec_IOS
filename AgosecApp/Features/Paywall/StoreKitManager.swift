import Foundation
import StoreKit
import SharedCore
import Networking
import UIComponents

@MainActor
class StoreKitManager: ObservableObject {
    @Published var product: Product?
    @Published var purchaseState: PurchaseState = .idle

    enum PurchaseState {
        case idle
        case loading
        case success
        case failure(Error)
    }

    private enum StoreKitManagerError: UserPresentableError {
        case invalidSignedTransaction

        var userMessage: String {
            "Unable to read transaction data. Please try again."
        }

        var isRetryable: Bool {
            true
        }
    }

    private let productId = Config.shared.subscriptionProductId
    private var toastManager: ToastManager?

    var isLoading: Bool {
        if case .loading = purchaseState {
            return true
        }
        return false
    }

    func setToastManager(_ manager: ToastManager) {
        self.toastManager = manager
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first

            if product == nil {
                toastManager?.show("Subscription product not available. Please try again later.", type: .error)
            }
        } catch {
            let message = ErrorMapper.userFriendlyMessage(from: error)
            toastManager?.show(message, type: .error, duration: 4.0, retryAction: {
                Task { await self.loadProducts() }
            })
        }
    }

    func purchase() async {
        guard let product = product else { return }

        purchaseState = .loading

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateEntitlement(with: transaction)
                await transaction.finish()
                purchaseState = .success

            case .userCancelled:
                purchaseState = .idle

            case .pending:
                purchaseState = .idle

            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failure(error)
            let message = ErrorMapper.userFriendlyMessage(from: error)
            toastManager?.show(message, type: .error)
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlement()
            toastManager?.show("Purchases restored successfully", type: .success)
        } catch {
            let message = ErrorMapper.userFriendlyMessage(from: error)
            toastManager?.show(message, type: .error, duration: 4.0, retryAction: {
                Task { await self.restorePurchases() }
            })
        }
    }

    private func checkVerified<T>(_ verification: VerificationResult<T>) throws -> T {
        switch verification {
        case .unverified:
            throw StoreError.transactionVerificationFailed
        case .verified(let signedType):
            return signedType
        }
    }

    private func updateEntitlement(with transaction: Transaction) async {
        let entitlement = EntitlementState(
            isActive: true,
            expiresAt: transaction.expirationDate,
            productId: transaction.productID
        )

        EntitlementEvaluator.saveEntitlement(entitlement)

        do {
            try await syncWithBackend(transaction: transaction)
        } catch {
            // Show error but don't fail the purchase (entitlement is already saved locally)
            let message = ErrorMapper.userFriendlyMessage(from: error)
            toastManager?.show("Purchase successful, but sync failed: \(message)", type: .info, duration: 4.0)
        }
    }

    private func syncWithBackend(transaction: Transaction) async throws {
        let authAPI = ServiceFactory.createAuthAPI(baseURL: Config.shared.backendBaseUrl)
        guard let signedTransactionJWS = String(bytes: transaction.jsonRepresentation, encoding: .utf8) else {
            throw StoreKitManagerError.invalidSignedTransaction
        }

        _ = try await authAPI.attachTransaction(
            originalTransactionId: transaction.originalID.description,
            signedTransactionJWS: signedTransactionJWS,
            appAccountToken: transaction.appAccountToken,
            deviceId: UIDevice.current.identifierForVendor?.uuidString
        )
    }

    private func refreshEntitlement() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                await updateEntitlement(with: transaction)
                await transaction.finish()
            } catch {}
        }
    }

    /// Check Apple for current subscription status and update cache
    /// Call this on app launch to keep entitlement fresh for keyboard
    func checkEntitlementOnLaunch() async {
        var foundActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productId {
                    if let expirationDate = transaction.expirationDate, expirationDate > Date() {
                        // Active subscription - save to cache
                        let entitlement = EntitlementState(
                            isActive: true,
                            expiresAt: expirationDate,
                            productId: transaction.productID
                        )
                        EntitlementEvaluator.saveEntitlement(entitlement)
                        foundActiveSubscription = true

                        // Also sync with backend for server-side validation
                        try? await syncWithBackend(transaction: transaction)
                    }
                }
            }
        }

        // If no active subscription found, clear the entitlement
        if !foundActiveSubscription {
            let expiredEntitlement = EntitlementState(isActive: false)
            EntitlementEvaluator.saveEntitlement(expiredEntitlement)
        }
    }
}

enum StoreError: Error {
    case transactionVerificationFailed
}

extension Product {
    var displayPrice: String {
        price.formatted(priceFormatStyle)
    }
}
