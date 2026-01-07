import Foundation
import SharedCore

public protocol AuthAPIProtocol {
    func attachTransaction(
        originalTransactionId: String,
        signedTransactionJWS: String,
        appAccountToken: UUID?,
        deviceId: String?
    ) async throws -> AuthResponse
}

public struct AuthResponse: Codable {
    public let accessToken: String
    public let userId: UUID
    public let entitlement: EntitlementState
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case userId = "user_id"
        case entitlement
    }
}

public class AuthAPI: AuthAPIProtocol {
    private let client: APIClientProtocol
    
    public init(client: APIClientProtocol) {
        self.client = client
    }
    
    public func attachTransaction(
        originalTransactionId: String,
        signedTransactionJWS: String,
        appAccountToken: UUID?,
        deviceId: String?
    ) async throws -> AuthResponse {
        let request = AttachTransactionRequest(
            originalTransactionId: originalTransactionId,
            signedTransactionJWS: signedTransactionJWS,
            appAccountToken: appAccountToken,
            deviceId: deviceId
        )
        
        let endpoint = APIEndpoint(
            path: "/v1/auth/attach-transaction",
            method: .post,
            body: try JSONEncoder().encode(request)
        )
        
        return try await client.request(endpoint)
    }
}

private struct AttachTransactionRequest: Codable {
    let originalTransactionId: String
    let signedTransactionJWS: String
    let appAccountToken: UUID?
    let deviceId: String?
    
    enum CodingKeys: String, CodingKey {
        case originalTransactionId = "original_transaction_id"
        case signedTransactionJWS = "signed_transaction_jws"
        case appAccountToken = "app_account_token"
        case deviceId = "device_id"
    }
}