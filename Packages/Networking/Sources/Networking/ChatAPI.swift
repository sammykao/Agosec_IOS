import Foundation
import SharedCore

public protocol ChatAPIProtocol {
    func sendMessage(
        sessionId: UUID,
        initMode: InitMode,
        turns: [ChatTurn],
        context: ContextDoc?,
        fieldContext: String?
    ) async throws -> ChatResponse
}

public enum InitMode: String, Codable {
    case summarizeContext = "summarize_context"
    case noContextIntro = "no_context_intro"
    case none = "none"
}

public struct ChatResponse: Codable {
    public let reply: String
    public let sessionId: UUID
    
    enum CodingKeys: String, CodingKey {
        case reply
        case sessionId = "session_id"
    }
}

public class ChatAPI: ChatAPIProtocol {
    private let client: APIClientProtocol
    private let accessToken: String
    
    public init(client: APIClientProtocol, accessToken: String) {
        self.client = client
        self.accessToken = accessToken
    }
    
    public func sendMessage(
        sessionId: UUID,
        initMode: InitMode,
        turns: [ChatTurn],
        context: ContextDoc?,
        fieldContext: String?
    ) async throws -> ChatResponse {
        let request = ChatRequest(
            sessionId: sessionId,
            initMode: initMode,
            turns: turns,
            context: context,
            fieldContext: fieldContext
        )
        
        let endpoint = APIEndpoint(
            path: "/v1/chat",
            method: .post,
            headers: ["Authorization": "Bearer \(accessToken)"],
            body: try JSONEncoder().encode(request)
        )
        
        return try await client.request(endpoint)
    }
}

private struct ChatRequest: Codable {
    let sessionId: UUID
    let initMode: InitMode
    let turns: [ChatTurn]
    let context: ContextPayload?
    let fieldContext: String?
    let client: ClientInfo
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case initMode = "init_mode"
        case turns
        case context
        case fieldContext = "field_context"
        case client
    }
    
    init(sessionId: UUID, initMode: InitMode, turns: [ChatTurn], context: ContextDoc?, fieldContext: String?) {
        self.sessionId = sessionId
        self.initMode = initMode
        self.turns = turns
        self.context = context.map { ContextPayload(raw: $0.rawText, summary: $0.summary) }
        self.fieldContext = fieldContext
        self.client = ClientInfo(platform: "ios_keyboard", version: "1.0")
    }
}

private struct ContextPayload: Codable {
    let raw: String?
    let summary: String?
}

private struct ClientInfo: Codable {
    let platform: String
    let version: String
}