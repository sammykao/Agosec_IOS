import Foundation
import StoreKit
import SharedCore

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
    
    private let productId = Config.shared.subscriptionProductId
    
    var isLoading: Bool {
        if case .loading = purchaseState {
            return true
        }
        return false
    }
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
        } catch {
            print("Failed to load products: \(error)")
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
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlement()
        } catch {
            print("Failed to restore purchases: \(error)")
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
        
        AppGroupStorage.shared.set(entitlement, for: "entitlement_state")
        
        do {
            try await syncWithBackend(transaction: transaction)
        } catch {
            print("Failed to sync with backend: \(error)")
        }
    }
    
    private func syncWithBackend(transaction: Transaction) async throws {
        let authAPI = AuthAPI(client: APIClient(baseURL: Config.shared.backendBaseUrl))
        
        _ = try await authAPI.attachTransaction(
            originalTransactionId: transaction.originalID.description,
            signedTransactionJWS: String(decoding: transaction.jsonRepresentation, as: UTF8.self),
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
            } catch {
                print("Failed to refresh entitlement: \(error)")
            }
        }
    }
}

enum StoreError: Error {
    case transactionVerificationFailed
}

extension Product {
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceFormatStyle.locale
        return formatter.string(from: NSNumber(value: Double(price))) ?? price.description
    }
}