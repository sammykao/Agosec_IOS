import SwiftUI
import UIKit
import KeyboardKit
import SharedCore
import Networking
import UIComponents

struct AgentChatView: View {
    let session: ChatSession
    let textDocumentProxy: UITextDocumentProxy
    let onNewSession: () -> Void
    let keyboardState: Keyboard.State?
    
    @State private var inputText = ""
    @State private var isLoading = false
    
    private var trimmedInput: String {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    @StateObject private var chatManager: ChatManager
    @EnvironmentObject var toastManager: ToastManager

    struct ChatLayout {
        let horizontalPadding: CGFloat
        let contentTopPadding: CGFloat
        let contentBottomPadding: CGFloat
        let messageSpacing: CGFloat
        let bubblePadding: CGFloat
        let bubbleCornerRadius: CGFloat
        let bubbleMaxWidth: CGFloat
        let messageFontSize: CGFloat
        let messageLineSpacing: CGFloat
        let avatarSize: CGFloat
        let inputSectionSpacing: CGFloat
        let inputFieldPadding: CGFloat
        let inputFieldCornerRadius: CGFloat
        let inputFieldFontSize: CGFloat
        let inputFieldSpacing: CGFloat
        let sendButtonSize: CGFloat
        let sendButtonIconSize: CGFloat
        let inputTopPadding: CGFloat
        let inputBottomPadding: CGFloat
        let actionSpacing: CGFloat
        let actionFontSize: CGFloat
        let actionHorizontalPadding: CGFloat
        let actionVerticalPadding: CGFloat
        let minTapTarget: CGFloat
        let inputFieldMinHeight: CGFloat
        let actionIconButtonSize: CGFloat
        let actionIconFontSize: CGFloat
    }
    
    init(
        session: ChatSession,
        textDocumentProxy: UITextDocumentProxy,
        keyboardState: Keyboard.State? = nil,
        onNewSession: @escaping () -> Void
    ) {
        self.session = session
        self.textDocumentProxy = textDocumentProxy
        self.keyboardState = keyboardState
        self.onNewSession = onNewSession
        self._chatManager = StateObject(wrappedValue: ChatManager(session: session))
    }
    
    var body: some View {
        let layout = layout
        VStack(spacing: 0) {
            chatMessagesView(layout: layout)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            inputView(layout: layout)
                .background(Color.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(Color.clear)
    }
    
    private func chatMessagesView(layout: ChatLayout) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { scrollView in
                VStack(spacing: layout.messageSpacing) {
                    if chatManager.messages.isEmpty {
                        EmptyChatStateView()
                    } else {
                        ForEach(chatManager.messages) { message in
                            MessageRowView(
                                message: message,
                                layout: layout,
                                onCopy: { copyToClipboard(message.content) },
                                onAutofill: { insertText(message.content) },
                                onReplace: { replaceText(message.content) }
                            )
                            .id(message.id)
                        }
                    }
                    
                    if isLoading {
                        InlineLoadingView(message: "Thinking...")
                            .id("loading-indicator")
                    }
                }
                .padding(.horizontal, layout.horizontalPadding)
                .padding(.top, layout.contentTopPadding)
                .padding(.bottom, layout.contentBottomPadding)
                .onAppear {
                    DispatchQueue.main.async {
                        scrollToBottom(scrollView)
                    }
                }
                .onChange(of: chatManager.messages.count) { _ in
                    scrollToBottom(scrollView)
                }
                .onChange(of: isLoading) { loading in
                    if loading {
                        scrollToBottom(scrollView)
                    }
                }
            }
        }
    }
    
    private func inputView(layout: ChatLayout) -> some View {
        let isSendDisabled = trimmedInput.isEmpty || isLoading
        let sendStyle = isSendDisabled
            ? AnyShapeStyle(Color.gray.opacity(0.3))
            : AnyShapeStyle(accentGradient)

        return VStack(spacing: layout.inputSectionSpacing) {
            Divider()
                .overlay(Color.gray.opacity(0.2))
            
            // Input display (read-only). Typing is handled by KeyboardKit below.
            HStack(spacing: layout.inputFieldSpacing) {
                ZStack(alignment: .leading) {
                    if inputText.isEmpty {
                        Text("Ask something...")
                            .font(.system(size: layout.inputFieldFontSize, weight: .regular))
                            .foregroundColor(Color.gray.opacity(0.6))
                            .padding(.vertical, layout.inputFieldPadding)
                            .padding(.horizontal, layout.inputFieldPadding + 2)
                    }

                    Text(inputText)
                        .font(.system(size: layout.inputFieldFontSize, weight: .regular))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        .padding(.vertical, layout.inputFieldPadding)
                        .padding(.horizontal, layout.inputFieldPadding + 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minHeight: layout.inputFieldMinHeight, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: layout.inputFieldCornerRadius)
                        .fill(Color.white.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: layout.inputFieldCornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.25),
                                    Color.purple.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(sendStyle)
                            .frame(width: layout.sendButtonSize, height: layout.sendButtonSize)
                            .shadow(color: Color.blue.opacity(isSendDisabled ? 0.0 : 0.25), radius: 6, x: 0, y: 4)

                        Image(systemName: "arrow.up")
                            .font(.system(size: layout.sendButtonIconSize, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(
                        width: max(layout.sendButtonSize, layout.minTapTarget),
                        height: max(layout.sendButtonSize, layout.minTapTarget)
                    )
                    .contentShape(Rectangle())
                }
                .disabled(isSendDisabled)
            }
            
            KeyboardKitChatKeyboardView(
                text: $inputText,
                onReturn: {
                    if !trimmedInput.isEmpty {
                        sendMessage()
                    }
                },
                sharedState: keyboardState
            )
            .opacity(isLoading ? 0.6 : 1.0)
            .allowsHitTesting(!isLoading)
        }
        .padding(.horizontal, layout.horizontalPadding)
        .padding(.top, layout.inputTopPadding)
        .padding(.bottom, layout.inputBottomPadding)
    }

    private var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.48, blue: 1.0),
                Color(red: 0.58, green: 0.0, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var layout: ChatLayout {
        let screenWidth = UIScreen.main.bounds.width
        let baseHorizontal: CGFloat = ResponsiveSystem.value(extraSmall: 12, small: 14, standard: 18)
        let horizontalPadding = min(max(baseHorizontal, screenWidth * 0.04), 24)
        let bubbleMaxWidth = min(screenWidth * 0.78, 420)

        return ChatLayout(
            horizontalPadding: horizontalPadding,
            contentTopPadding: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 14),
            contentBottomPadding: ResponsiveSystem.value(extraSmall: 14, small: 18, standard: 22),
            messageSpacing: ResponsiveSystem.value(extraSmall: 12, small: 14, standard: 16),
            bubblePadding: ResponsiveSystem.value(extraSmall: 10, small: 12, standard: 14),
            bubbleCornerRadius: ResponsiveSystem.value(extraSmall: 16, small: 18, standard: 20),
            bubbleMaxWidth: bubbleMaxWidth,
            messageFontSize: ResponsiveSystem.value(extraSmall: 14, small: 15, standard: 16),
            messageLineSpacing: ResponsiveSystem.value(extraSmall: 2, small: 3, standard: 4),
            avatarSize: ResponsiveSystem.value(extraSmall: 18, small: 20, standard: 22),
            inputSectionSpacing: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 12),
            inputFieldPadding: ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10),
            inputFieldCornerRadius: ResponsiveSystem.value(extraSmall: 16, small: 18, standard: 20),
            inputFieldFontSize: ResponsiveSystem.value(extraSmall: 15, small: 16, standard: 17),
            inputFieldSpacing: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 12),
            sendButtonSize: ResponsiveSystem.value(extraSmall: 34, small: 36, standard: 40),
            sendButtonIconSize: ResponsiveSystem.value(extraSmall: 16, small: 18, standard: 20),
            inputTopPadding: ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10),
            inputBottomPadding: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 12),
            actionSpacing: ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10),
            actionFontSize: ResponsiveSystem.value(extraSmall: 11, small: 12, standard: 13),
            actionHorizontalPadding: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 12),
            actionVerticalPadding: ResponsiveSystem.value(extraSmall: 4, small: 5, standard: 6),
            minTapTarget: 44,
            inputFieldMinHeight: 44,
            actionIconButtonSize: ResponsiveSystem.value(extraSmall: 26, small: 28, standard: 30),
            actionIconFontSize: ResponsiveSystem.value(extraSmall: 13, small: 14, standard: 15)
        )
    }
    
    private func sendMessage() {
        let messageText = trimmedInput
        guard !messageText.isEmpty else { return }
        
        inputText = ""
        
        sendMessageWithText(messageText)
    }
    
    private func sendMessageWithText(_ text: String) {
        let userMessage = ChatMessage(
            id: UUID(),
            content: text,
            isUser: true,
            timestamp: Date()
        )
        
        chatManager.addMessage(userMessage)
        isLoading = true
        
        Task {
            do {
                try await chatManager.sendMessage(text)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    
                    // Remove the failed user message so retry can re-add it
                    chatManager.removeLastMessage()
                    
                    let message = ErrorMapper.userFriendlyMessage(from: error)
                    let shouldRetry = ErrorMapper.shouldShowRetry(for: error)
                    
                    toastManager.show(
                        message,
                        type: .error,
                        duration: shouldRetry ? 5.0 : 3.0,
                        retryAction: shouldRetry ? { [text] in
                            self.sendMessageWithText(text)
                        } : nil
                    )
                }
            }
        }
    }
    
    private func scrollToBottom(_ scrollView: ScrollViewProxy) {
        withAnimation {
            if isLoading {
                scrollView.scrollTo("loading-indicator", anchor: .bottom)
            } else if let lastMessage = chatManager.messages.last {
                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
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
    let layout: AgentChatView.ChatLayout
    let onCopy: () -> Void
    let onAutofill: () -> Void
    let onReplace: () -> Void
    
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 0) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: layout.actionSpacing) {
                HStack(alignment: .bottom, spacing: ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10)) {
                    if !message.isUser {
                        Group {
                            if let uiImage = LogoLoader.loadAgosecLogo() {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image(systemName: "sparkles")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(userBubbleGradient)
                            }
                        }
                        .frame(width: layout.avatarSize, height: layout.avatarSize)
                        .padding(.bottom, 2)
                    }

                    messageContent
                }

                if !message.isUser {
                    actionButtons
                }
            }

            if !message.isUser { Spacer(minLength: 0) }
        }
    }
    
    private var messageContent: some View {
        let fillStyle: AnyShapeStyle = message.isUser
            ? AnyShapeStyle(userBubbleGradient)
            : AnyShapeStyle(Color.white.opacity(0.92))

        return Text(message.content)
            .font(.system(size: layout.messageFontSize, weight: .regular))
            .lineSpacing(layout.messageLineSpacing)
            .foregroundColor(message.isUser ? .white : Color(red: 0.15, green: 0.15, blue: 0.2))
            .padding(layout.bubblePadding)
            .frame(maxWidth: layout.bubbleMaxWidth, alignment: message.isUser ? .trailing : .leading)
            .background(
                RoundedRectangle(cornerRadius: layout.bubbleCornerRadius)
                    .fill(fillStyle)
            )
            .overlay(
                RoundedRectangle(cornerRadius: layout.bubbleCornerRadius)
                    .stroke(
                        message.isUser
                            ? AnyShapeStyle(Color.white.opacity(0.25))
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.8), Color.blue.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            ),
                        lineWidth: 1
                    )
            )
            .shadow(color: message.isUser ? Color.blue.opacity(0.25) : Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .textSelection(.enabled)
    }

    private var userBubbleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.48, blue: 1.0),
                Color(red: 0.58, green: 0.0, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var actionButtons: some View {
        ActionButtonsView(
            layout: layout,
            onCopy: onCopy,
            onAutofill: onAutofill,
            onReplace: onReplace
        )
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

enum ChatError: Error {
    case noAPIAccess
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .noAPIAccess:
            return "ChatError.noAPIAccess"
        case .networkError:
            return "ChatError.networkError"
        }
    }
}

// MARK: - Action Buttons View

struct ActionButtonsView: View {
    let layout: AgentChatView.ChatLayout
    let onCopy: () -> Void
    let onAutofill: () -> Void
    let onReplace: () -> Void
    
    @State private var copyScale: CGFloat = 1.0
    @State private var insertScale: CGFloat = 1.0
    @State private var replaceScale: CGFloat = 1.0

    private var useCompactActions: Bool {
        ResponsiveSystem.isExtraSmallScreen || ResponsiveSystem.isSmallScreen
    }
    
    var body: some View {
        HStack(spacing: layout.actionSpacing) {
            if useCompactActions {
                actionIconButton(
                    title: "Copy",
                    systemImage: "doc.on.doc",
                    scale: $copyScale,
                    action: onCopy
                )
                
                actionIconButton(
                    title: "Insert",
                    systemImage: "text.insert",
                    scale: $insertScale,
                    action: onAutofill
                )
                
                actionIconButton(
                    title: "Replace",
                    systemImage: "arrow.2.squarepath",
                    scale: $replaceScale,
                    action: onReplace
                )
            } else {
                actionButton(
                    title: "Copy",
                    systemImage: "doc.on.doc",
                    scale: $copyScale,
                    action: onCopy
                )
                
                actionButton(
                    title: "Insert",
                    systemImage: "text.insert",
                    scale: $insertScale,
                    action: onAutofill
                )
                
                actionButton(
                    title: "Replace",
                    systemImage: "arrow.2.squarepath",
                    scale: $replaceScale,
                    action: onReplace
                )
            }
        }
        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
    }
    
    private func actionButton(
        title: String,
        systemImage: String,
        scale: Binding<CGFloat>,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            performAction(scale: scale, action: action)
        }) {
            Label(title, systemImage: systemImage)
                .font(.system(size: layout.actionFontSize, weight: .semibold))
                .padding(.horizontal, layout.actionHorizontalPadding)
                .padding(.vertical, layout.actionVerticalPadding)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                )
                .frame(minHeight: layout.minTapTarget)
                .contentShape(Rectangle())
        }
        .scaleEffect(scale.wrappedValue)
        .buttonStyle(PlainButtonStyle())
    }

    private func actionIconButton(
        title: String,
        systemImage: String,
        scale: Binding<CGFloat>,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            performAction(scale: scale, action: action)
        }) {
            Image(systemName: systemImage)
                .font(.system(size: layout.actionIconFontSize, weight: .semibold))
                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                .frame(width: layout.actionIconButtonSize, height: layout.actionIconButtonSize)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                )
                .overlay(
                    Circle()
                        .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                )
                .frame(minWidth: layout.minTapTarget, minHeight: layout.minTapTarget)
                .contentShape(Rectangle())
                .accessibilityLabel(title)
        }
        .scaleEffect(scale.wrappedValue)
        .buttonStyle(PlainButtonStyle())
    }

    private func performAction(scale: Binding<CGFloat>, action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale.wrappedValue = 0.85
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale.wrappedValue = 1.0
            }
        }
        UIImpactFeedbackGenerator.safeImpact(.light)
        action()
    }
}
