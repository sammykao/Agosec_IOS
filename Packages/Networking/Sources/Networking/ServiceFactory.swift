import Foundation
import SharedCore

/// Factory for creating API service instances
/// Switches between real and mock implementations based on BuildMode
public class ServiceFactory {

    /// Creates an AuthAPI instance (real or mock based on BuildMode)
    public static func createAuthAPI(baseURL: String) -> AuthAPIProtocol {
        if BuildMode.isMockBackend {
            return MockAuthAPI()
        }
        return AuthAPI(client: APIClient(baseURL: baseURL))
    }

    /// Creates a ChatAPI instance (real or mock based on BuildMode)
    /// - Parameters:
    ///   - baseURL: Backend base URL
    ///   - accessToken: User access token (required for real API, optional for mock)
    ///   - sessionId: Optional session ID for mock API
    public static func createChatAPI(
        baseURL: String,
        accessToken: String? = nil,
        sessionId: UUID? = nil
    ) throws -> ChatAPIProtocol {
        if BuildMode.isMockBackend {
            return MockChatAPI(sessionId: sessionId ?? UUID())
        }

        guard let accessToken = accessToken else {
            throw ServiceFactoryError.missingAccessToken(service: "ChatAPI")
        }

        return ChatAPI(client: APIClient(baseURL: baseURL), accessToken: accessToken)
    }

    /// Creates an EntitlementAPI instance (real or mock based on BuildMode)
    /// - Parameters:
    ///   - baseURL: Backend base URL
    ///   - accessToken: User access token (required for real API, optional for mock)
    public static func createEntitlementAPI(
        baseURL: String,
        accessToken: String? = nil
    ) throws -> EntitlementAPIProtocol {
        if BuildMode.isMockBackend {
            return MockEntitlementAPI()
        }

        guard let accessToken = accessToken else {
            throw ServiceFactoryError.missingAccessToken(service: "EntitlementAPI")
        }

        return EntitlementAPI(client: APIClient(baseURL: baseURL), accessToken: accessToken)
    }
}
