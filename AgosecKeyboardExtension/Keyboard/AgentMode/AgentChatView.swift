import SwiftUI
import UIKit

struct AgentChatView: View {
    let session: ChatSession
    let textDocumentProxy: UITextDocumentProxy
    let onNewSession: () -> Void
    
    @State private var inputText = ""
    @State private var isLoading = false
    @StateObject private var chatManager: ChatManager
    
    init(session: ChatSession, textDocumentProxy: UITextDocumentProxy, onNewSession: @escaping () -> Void) {
        self.session = session
        self.textDocumentProxy = textDocumentProxy
        self.onNewSession = onNewSession
        self._chatManager = StateObject(wrappedValue: ChatManager(session: session))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            chatMessagesView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            inputView
                .background(Color.gray.opacity(0.1))
        }
    }
    
    private var chatMessagesView: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 12) {
                    ForEach(chatManager.messages) { message in
                        MessageRowView(
                            message: message,
                            onCopy: { copyToClipboard(message.content) },
                            onAutofill: { insertText(message.content) },
                            onReplace: { replaceText(message.content) }
                        )
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .padding()
                .onReceive(chatManager.$messages) { _ in
                    if let lastMessage = chatManager.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 8) {
                TextField("Ask something...", text: $inputText, axis: .vertical)
                    .lineLimit(1...3)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(inputText.isEmpty ? .gray : .blue)
                }
                .disabled(inputText.isEmpty || isLoading)
            }
            .padding(8)
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            content: inputText,
            isUser: true,
            timestamp: Date()
        )
        
        chatManager.addMessage(userMessage)
        
        let messageText = inputText
        inputText = ""
        isLoading = true
        
        Task {
            do {
                let response = try await chatManager.sendMessage(messageText)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    // Show error
                }
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    private func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
    
    private func replaceText(_ text: String) {
        // Simple heuristic: delete last word/phrase and insert new text
        for _ in 0..<10 {
            textDocumentProxy.deleteBackward()
        }
        textDocumentProxy.insertText(text)
    }
}

struct MessageRowView: View {
    let message: ChatMessage
    let onCopy: () -> Void
    let onAutofill: () -> Void
    let onReplace: () -> Void
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 8) {
                    if !message.isUser {
                        Image(systemName: "brain")
                            .font(.system(size: 16))
                            .foregroundColor(.purple)
                    }
                    
                    messageContent
                }
                
                if !message.isUser {
                    actionButtons
                }
            }
            
            if !message.isUser { Spacer() }
        }
    }
    
    private var messageContent: some View {
        Text(message.content)
            .padding(12)
            .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(message.isUser ? .white : .primary)
            .cornerRadius(16)
            .textSelection(.enabled)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button(action: onCopy) {
                Label("Copy", systemImage: "doc.on.doc")
                    .font(.system(size: 12))
            }
            
            Button(action: onAutofill) {
                Label("Insert", systemImage: "text.insert")
                    .font(.system(size: 12))
            }
            
            Button(action: onReplace) {
                Label("Replace", systemImage: "arrow.2.squarepath")
                    .font(.system(size: 12))
            }
        }
        .foregroundColor(.blue)
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
}

class ChatManager: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    private let session: ChatSession
    private let chatAPI: ChatAPIProtocol?
    
    init(session: ChatSession) {
        self.session = session
        
        if let accessToken: String = AppGroupStorage.shared.get(String.self, for: "access_token") {
            self.chatAPI = ChatAPI(
                client: APIClient(baseURL: Config.shared.backendBaseUrl),
                accessToken: accessToken
            )
        } else {
            self.chatAPI = nil
        }
        
        // Convert existing turns to messages
        for turn in session.turns {
            let message = ChatMessage(
                id: UUID(),
                content: turn.text,
                isUser: turn.role == .user,
                timestamp: turn.timestamp
            )
            messages.append(message)
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
    
    func sendMessage(_ text: String) async throws {
        guard let chatAPI = chatAPI else {
            throw ChatError.noAPIAccess
        }
        
        let userTurn = ChatTurn(role: .user, text: text)
        session.turns.append(userTurn)
        
        let recentTurns = Array(session.turns.suffix(Config.shared.featureFlags.maxTurnsSent))
        
        let response = try await chatAPI.sendMessage(
            sessionId: session.sessionId,
            initMode: .none,
            turns: recentTurns,
            context: session.context,
            fieldContext: nil
        )
        
        let assistantTurn = ChatTurn(role: .assistant, text: response.reply)
        session.turns.append(assistantTurn)
        
        let message = ChatMessage(
            id: UUID(),
            content: response.reply,
            isUser: false,
            timestamp: Date()
        )
        
        await MainActor.run {
            messages.append(message)
        }
    }
}

enum ChatError: Error {
    case noAPIAccess
    case networkError
}