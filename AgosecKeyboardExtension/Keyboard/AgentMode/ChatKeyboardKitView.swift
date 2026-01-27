import KeyboardKit
import SwiftUI

final class ChatKeyboardController: KeyboardController, ObservableObject {
    let state: Keyboard.State
    let services: Keyboard.Services

    private var text: Binding<String>
    private var cursorIndex: Int

    init(text: Binding<String>, onReturn: @escaping () -> Void, sharedState: Keyboard.State? = nil) {
        self.text = text
        self.cursorIndex = text.wrappedValue.count
        let state = Keyboard.State()
        state.setup(for: .agosec)
        if let sharedState = sharedState {
            state.keyboardContext.locale = sharedState.keyboardContext.locale
            state.keyboardContext.locales = sharedState.keyboardContext.locales
        }
        self.state = state
        self.state.keyboardContext.keyboardType = .alphabetic
        self.state.keyboardContext.keyboardInputType = .text
        self.state.keyboardContext.returnKeyTypeOverride = .send
        self.services = Keyboard.Services(state: self.state)
        self.services.actionHandler = ChatKeyboardActionHandler(controller: self, onReturn: onReturn)
    }

    func syncCursorToEnd() {
        cursorIndex = text.wrappedValue.count
    }

    func adjustTextPosition(by characterOffset: Int) {
        let maxIndex = text.wrappedValue.count
        cursorIndex = min(max(cursorIndex + characterOffset, 0), maxIndex)
    }

    func deleteBackward() {
        guard !text.wrappedValue.isEmpty else { return }
        let currentIndex = min(max(cursorIndex, 0), text.wrappedValue.count)
        let deleteIndex = max(currentIndex - 1, 0)
        let startIndex = text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: deleteIndex)
        let endIndex = text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: currentIndex)
        text.wrappedValue.removeSubrange(startIndex..<endIndex)
        cursorIndex = deleteIndex
    }

    func deleteBackward(times: Int) {
        guard times > 0 else { return }
        for _ in 0..<times {
            deleteBackward()
        }
    }

    func dismissKeyboard() {}

    func endSentence(withText text: String) {
        insertText(text)
    }

    func insertDiacritic(_ diacritic: Keyboard.Diacritic) {
        insertText(diacritic.char)
    }

    func insertText(_ text: String) {
        guard !text.isEmpty else { return }
        let currentIndex = min(max(cursorIndex, 0), self.text.wrappedValue.count)
        let insertionIndex = self.text.wrappedValue.index(self.text.wrappedValue.startIndex, offsetBy: currentIndex)
        self.text.wrappedValue.insert(contentsOf: text, at: insertionIndex)
        cursorIndex = currentIndex + text.count
    }

    func openUrl(_ url: URL?) {}

    func performAutocomplete() {}

    func performDictation() {}

    func selectNextLocale() {
        state.keyboardContext.selectNextLocale()
    }

    func setKeyboardCase(_ `case`: Keyboard.KeyboardCase) {
        state.keyboardContext.keyboardCase = `case`
    }

    func setKeyboardInputType(_ type: Keyboard.InputType) {
        state.keyboardContext.keyboardInputType = type
    }

    func setKeyboardType(_ type: Keyboard.KeyboardType) {
        state.keyboardContext.keyboardType = type
    }
}

final class ChatKeyboardActionHandler: KeyboardAction.StandardActionHandler {
    private let onReturn: () -> Void

    init(controller: KeyboardController, onReturn: @escaping () -> Void) {
        self.onReturn = onReturn
        super.init(controller: controller)
    }

    override func handle(_ action: KeyboardAction) {
        switch action {
        case .primary:
            onReturn()
        default:
            super.handle(action)
        }
    }
}

struct KeyboardKitChatKeyboardView: View {
    @Binding var text: String
    let onReturn: () -> Void

    @StateObject private var controller: ChatKeyboardController

    init(text: Binding<String>, onReturn: @escaping () -> Void, sharedState: Keyboard.State? = nil) {
        self._text = text
        self.onReturn = onReturn
        _controller = StateObject(
            wrappedValue: ChatKeyboardController(
                text: text,
                onReturn: onReturn,
                sharedState: sharedState
            )
        )
    }

    var body: some View {
        KeyboardView(
            services: controller.services,
            buttonContent: { $0.view },
            buttonView: { $0.view }
        )
        .keyboardInputToolbarDisplayMode(.none)
        .onChange(of: text) { _ in
            controller.syncCursorToEnd()
        }
    }
}
