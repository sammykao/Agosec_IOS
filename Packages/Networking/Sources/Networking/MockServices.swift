import Foundation
import SharedCore

// MARK: - Mock Auth API

public class MockAuthAPI: AuthAPIProtocol {
    public init() {}
    
    public func attachTransaction(
        originalTransactionId: String,
        signedTransactionJWS: String,
        appAccountToken: UUID?,
        deviceId: String?
    ) async throws -> AuthResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(BuildMode.mockNetworkDelay * 1_000_000_000))
        
        // Generate mock access token
        let mockToken = "mock_token_\(UUID().uuidString)"
        let mockUserId = UUID()
        
        // Create mock entitlement (active for 30 days)
        let mockEntitlement = EntitlementState(
            isActive: true,
            expiresAt: Date().addingTimeInterval(86400 * 30), // 30 days
            productId: "com.agosec.keyboard.pro"
        )
        
        return AuthResponse(
            accessToken: mockToken,
            userId: mockUserId,
            entitlement: mockEntitlement
        )
    }
}

// MARK: - Mock Chat API

public class MockChatAPI: ChatAPIProtocol {
    private let sessionId: UUID
    
    public init(sessionId: UUID = UUID()) {
        self.sessionId = sessionId
    }
    
    public func sendMessage(
        sessionId: UUID,
        initMode: InitMode,
        turns: [ChatTurn],
        context: ContextDoc?,
        fieldContext: String?
    ) async throws -> ChatResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(BuildMode.mockNetworkDelay * 1_000_000_000))
        
        let response: String
        
        switch initMode {
        case .summarizeContext:
            // Mock context summary response
            if let context = context {
                response = "I've reviewed your screenshots. I can see \(context.rawText.prefix(50))... Let me help you with that. What would you like me to do?"
            } else {
                response = "I've reviewed your context. How can I assist you?"
            }
            
        case .noContextIntro:
            // Mock introduction message
            response = "Hi! I'm your AI assistant. I can help you write messages, answer questions, and provide context-aware responses. What can I help you with today?"
            
        case .none:
            // Generate contextual response based on last user message
            if let lastTurn = turns.last, lastTurn.role == .user {
                response = generateMockResponse(to: lastTurn.text, context: context)
            } else {
                response = "I understand. How can I help you further?"
            }
        }
        
        return ChatResponse(
            reply: response,
            sessionId: sessionId
        )
    }
    
    private func generateMockResponse(to userMessage: String, context: ContextDoc?) -> String {
        let lowercased = userMessage.lowercased()
        
        // Context-aware responses
        if let context = context {
            if lowercased.contains("lunch") || lowercased.contains("food") || lowercased.contains("eat") {
                return "Based on your conversation about lunch plans, I'd suggest checking out some local restaurants. Would you like me to help you draft a message to coordinate?"
            }
            if lowercased.contains("meeting") || lowercased.contains("schedule") {
                return "I see you're discussing meeting schedules. I can help you organize and communicate your availability. What would you like to do?"
            }
            if lowercased.contains("email") || lowercased.contains("message") {
                return "I can help you draft a professional response based on the context I've reviewed. What tone would you like - formal or casual?"
            }
        }
        
        // General responses based on keywords
        let responses: [String]
        if lowercased.contains("help") || lowercased.contains("assist") {
            responses = [
                "I'd be happy to help! What specifically would you like assistance with?",
                "I'm here to help. Can you tell me more about what you need?",
                "Let me help you with that. What would you like me to do?"
            ]
        } else if lowercased.contains("write") || lowercased.contains("draft") {
            responses = [
                "I can help you write that. What's the message about?",
                "Sure! What kind of message are you looking to draft?",
                "I'll help you craft that message. What tone are you going for?"
            ]
        } else if lowercased.contains("question") || lowercased.contains("?") {
            responses = [
                "That's a great question! Let me think about that...",
                "I understand your question. Here's what I think...",
                "Good question! Based on what I know, here's my perspective..."
            ]
        } else {
            responses = [
                "I understand what you're saying. Let me help you with that.",
                "That's a great point! Here's what I think...",
                "Based on your message, I'd suggest the following approach.",
                "I can definitely help with that. Let me provide some insights.",
                "Interesting! Here's my perspective on that...",
                "I see what you mean. Here's how I can help...",
                "Thanks for sharing that. Let me help you work through it."
            ]
        }
        
        return responses.randomElement() ?? "I'm here to help. What would you like to do?"
    }
}

// MARK: - Mock Entitlement API

public class MockEntitlementAPI: EntitlementAPIProtocol {
    public init() {}
    
    public func fetchEntitlement() async throws -> EntitlementState {
        // Simulate network delay (shorter for entitlement checks)
        try await Task.sleep(nanoseconds: UInt64(BuildMode.mockNetworkDelay * 500_000_000))
        
        // Return active subscription (30 days from now)
        return EntitlementState(
            isActive: true,
            expiresAt: Date().addingTimeInterval(86400 * 30), // 30 days
            productId: "com.agosec.keyboard.pro"
        )
    }
}

