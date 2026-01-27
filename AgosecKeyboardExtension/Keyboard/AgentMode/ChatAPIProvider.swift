import Foundation
import Networking
import SharedCore

enum ChatAPIProvider {
    static func makeChatAPI(sessionId: UUID?) -> ChatAPIProtocol? {
        let accessToken: String? = AppGroupStorage.shared.get(String.self, for: AppGroupKeys.accessToken)

        if BuildMode.isMockBackend {
            return ServiceFactory.createChatAPI(
                baseURL: Config.shared.backendBaseUrl,
                accessToken: accessToken,
                sessionId: sessionId
            )
        }

        guard let accessToken = accessToken else {
            return nil
        }

        return ServiceFactory.createChatAPI(
            baseURL: Config.shared.backendBaseUrl,
            accessToken: accessToken,
            sessionId: sessionId
        )
    }
}
