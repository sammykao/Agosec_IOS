import Foundation
import Networking
import SharedCore

enum ChatAPIProvider {
    static func makeChatAPI(sessionId: UUID?) -> ChatAPIProtocol? {
        let accessToken: String? = AppGroupStorage.shared.get(String.self, for: AppGroupKeys.accessToken)

        do {
            return try ServiceFactory.createChatAPI(
                baseURL: Config.shared.backendBaseUrl,
                accessToken: accessToken,
                sessionId: sessionId
            )
        } catch {
            return nil
        }
    }
}
