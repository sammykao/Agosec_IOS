import SwiftUI
import UIKit
import KeyboardKit
import SharedCore
import UIComponents

struct AgentChatView: View {
    let session: ChatSession
    let textDocumentProxy: UITextDocumentProxy
    let onNewSession: () -> Void
    let keyboardState: Keyboard.State?

    @State var inputText = ""
    @State var isLoading = false

    private var trimmedInput: String {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    @StateObject var chatManager: ChatManager
    @EnvironmentObject var toastManager: ToastManager

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
}
