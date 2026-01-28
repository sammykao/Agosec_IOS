import SwiftUI
import UIKit
import KeyboardKit
import SharedCore
import UIComponents

extension AgentChatView {
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

    private var trimmedInput: String {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines)
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

    var layout: ChatLayout {
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
}

extension AgentChatView {
    func chatMessagesView(layout: ChatLayout) -> some View {
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

    func inputView(layout: ChatLayout) -> some View {
        let isSendDisabled = trimmedInput.isEmpty || isLoading
        let sendStyle = isSendDisabled
            ? AnyShapeStyle(Color.gray.opacity(0.3))
            : AnyShapeStyle(accentGradient)

        return VStack(spacing: layout.inputSectionSpacing) {
            inputDivider

            HStack(spacing: layout.inputFieldSpacing) {
                inputField(layout: layout)
                sendButton(layout: layout, isSendDisabled: isSendDisabled, sendStyle: sendStyle)
            }

            keyboardInput(layout: layout)
        }
        .padding(.horizontal, layout.horizontalPadding)
        .padding(.top, layout.inputTopPadding)
        .padding(.bottom, layout.inputBottomPadding)
    }

    private var inputDivider: some View {
        Divider()
            .overlay(Color.gray.opacity(0.2))
    }

    private func inputField(layout: ChatLayout) -> some View {
        ZStack(alignment: .leading) {
            inputPlaceholder(layout: layout)
            inputTextView(layout: layout)
        }
        .frame(minHeight: layout.inputFieldMinHeight, alignment: .leading)
        .background(inputFieldBackground(layout: layout))
        .overlay(inputFieldBorder(layout: layout))
    }

    @ViewBuilder
    private func inputPlaceholder(layout: ChatLayout) -> some View {
        if inputText.isEmpty {
            Text("Ask something...")
                .font(.system(size: layout.inputFieldFontSize, weight: .regular))
                .foregroundColor(Color.gray.opacity(0.6))
                .padding(.vertical, layout.inputFieldPadding)
                .padding(.horizontal, layout.inputFieldPadding + 2)
        }
    }

    private func inputTextView(layout: ChatLayout) -> some View {
        Text(inputText)
            .font(.system(size: layout.inputFieldFontSize, weight: .regular))
            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
            .padding(.vertical, layout.inputFieldPadding)
            .padding(.horizontal, layout.inputFieldPadding + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func inputFieldBackground(layout: ChatLayout) -> some View {
        RoundedRectangle(cornerRadius: layout.inputFieldCornerRadius)
            .fill(Color.white.opacity(0.9))
    }

    private func inputFieldBorder(layout: ChatLayout) -> some View {
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
    }

    private func sendButton(
        layout: ChatLayout,
        isSendDisabled: Bool,
        sendStyle: AnyShapeStyle
    ) -> some View {
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

    private func keyboardInput(layout: ChatLayout) -> some View {
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
}

extension AgentChatView {
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
        for _ in 0..<10 {
            textDocumentProxy.deleteBackward()
        }
        textDocumentProxy.insertText(text)
    }
}
