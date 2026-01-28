import Combine
import Foundation
import Networking
import SharedCore

class ChatManager: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    private var session: ChatSession
    private let chatAPI: ChatAPIProtocol?

    init(session: ChatSession) {
        self.session = session
        self.chatAPI = ChatAPIProvider.makeChatAPI(sessionId: session.sessionId)

        // Convert existing turns to messages
        messages = session.turns.map { turn in
            ChatMessage(
                id: UUID(),
                content: turn.text,
                isUser: turn.role == .user,
                timestamp: turn.timestamp
            )
        }
    }

    func addMessage(_ message: ChatMessage) {
        messages.append(message)

        // Also add to session turns
        let turn = ChatTurn(
            role: message.isUser ? .user : .assistant,
            text: message.content,
            timestamp: message.timestamp
        )
        session.turns.append(turn)
    }

    func removeLastMessage() {
        guard !messages.isEmpty else { return }
        messages.removeLast()

        // Also remove from session turns
        if !session.turns.isEmpty {
            session.turns.removeLast()
        }
    }

    func sendMessage(_ text: String) async throws {
        guard let chatAPI = chatAPI else {
            throw ChatError.noAPIAccess
        }

        // Note: User turn is already added via addMessage() before this is called
        let recentTurns = Array(session.turns.suffix(Config.shared.featureFlags.maxTurnsSent))

        let response = try await chatAPI.sendMessage(
            sessionId: session.sessionId,
            initMode: .none,
            turns: recentTurns,
            context: session.context,
            fieldContext: nil
        )

        let assistantTurn = ChatTurn(role: .assistant, text: response.reply)

        let message = ChatMessage(
            id: UUID(),
            content: response.reply,
            isUser: false,
            timestamp: Date()
        )

        await MainActor.run {
            session.turns.append(assistantTurn)
            messages.append(message)
        }
    }
}
