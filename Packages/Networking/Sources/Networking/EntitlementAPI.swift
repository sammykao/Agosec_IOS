import Foundation
import SharedCore

public protocol EntitlementAPIProtocol {
    func fetchEntitlement() async throws -> EntitlementState
}

public class EntitlementAPI: EntitlementAPIProtocol {
    private let client: APIClientProtocol
    private let accessToken: String
    
    public init(client: APIClientProtocol, accessToken: String) {
        self.client = client
        self.accessToken = accessToken
    }
    
    public func fetchEntitlement() async throws -> EntitlementState {
        let endpoint = APIEndpoint(
            path: "/v1/entitlement",
            method: .get,
            headers: ["Authorization": "Bearer \(accessToken)"]
        )
        
        return try await client.request(endpoint)
    }
}