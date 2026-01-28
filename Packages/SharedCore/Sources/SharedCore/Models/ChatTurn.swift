import Foundation

public struct ChatTurn: Codable, Equatable {
    public let role: Role
    public let text: String
    public let timestamp: Date

    public enum Role: String, Codable {
        case user
        case assistant
    }

    public init(role: Role, text: String, timestamp: Date = Date()) {
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}

public struct ChatSession: Codable {
    public let sessionId: UUID
    public var turns: [ChatTurn]
    public var context: ContextDoc?
    public var createdAt: Date

    public init(sessionId: UUID = UUID(), turns: [ChatTurn] = [], context: ContextDoc? = nil) {
        self.sessionId = sessionId
        self.turns = turns
        self.context = context
        self.createdAt = Date()
    }
}

public struct ContextDoc: Codable {
    public let rawText: String
    public let summary: String?
    public let createdAt: Date

    public init(rawText: String, summary: String? = nil) {
        self.rawText = rawText
        self.summary = summary
        self.createdAt = Date()
    }
}
