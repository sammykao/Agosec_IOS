import KeyboardKit
import SwiftUI

final class AgentTextInputController: KeyboardController, ObservableObject {
    let state: Keyboard.State
    let services: Keyboard.Services

    private var text: Binding<String>
    private var cursorIndex: Int

    init(text: Binding<String>, sharedState: Keyboard.State) {
        self.text = text
        self.cursorIndex = text.wrappedValue.count
        self.state = sharedState
        self.services = Keyboard.Services(state: sharedState)
        self.state.keyboardContext.keyboardType = .alphabetic
        self.state.keyboardContext.keyboardInputType = .text
        self.state.keyboardContext.returnKeyTypeOverride = .send
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

    func replaceLastWord(with replacement: String, addTrailingSpace: Bool) {
        let currentText = text.wrappedValue
        let separators = CharacterSet.whitespacesAndNewlines
        let range = currentText.rangeOfCharacter(from: separators, options: .backwards)
        let prefix: String
        if let range = range {
            prefix = String(currentText[..<range.upperBound])
        } else {
            prefix = ""
        }
        let suffix = addTrailingSpace ? " " : ""
        text.wrappedValue = prefix + replacement + suffix
        cursorIndex = text.wrappedValue.count
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

final class AgentKeyboardActionHandler: KeyboardActionHandler {
    private let onReturn: () -> Void
    private let standard: KeyboardAction.StandardActionHandler

    init(controller: KeyboardController, onReturn: @escaping () -> Void) {
        self.onReturn = onReturn
        self.standard = KeyboardAction.StandardActionHandler.standard(for: controller)
    }

    func canHandle(_ gesture: Keyboard.Gesture, on action: KeyboardAction) -> Bool {
        standard.canHandle(gesture, on: action)
    }

    func handle(_ action: KeyboardAction) {
        switch action {
        case .primary:
            onReturn()
        default:
            standard.handle(action)
        }
    }

    func handle(_ gesture: Keyboard.Gesture, on action: KeyboardAction) {
        standard.handle(gesture, on: action)
    }

    func handle(_ suggestion: Autocomplete.Suggestion) {
        standard.handle(suggestion)
    }

    func handleDrag(on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) {
        standard.handleDrag(on: action, from: startLocation, to: currentLocation)
    }

    func triggerFeedback(for gesture: Keyboard.Gesture, on action: KeyboardAction) {
        standard.triggerFeedback(for: gesture, on: action)
    }

    func triggerAudioFeedback(_ feedback: Feedback.Audio) {
        standard.triggerAudioFeedback(feedback)
    }

    func triggerHapticFeedback(_ feedback: Feedback.Haptic) {
        standard.triggerHapticFeedback(feedback)
    }
}

struct AgentKeyboardKitTypingView: View {
    let controller: KeyboardInputViewController
    @Binding var text: String

    @StateObject private var textController: AgentTextInputController
    @State private var previousReturnKeyOverride: Keyboard.ReturnKeyType?

    init(controller: KeyboardInputViewController, text: Binding<String>) {
        self.controller = controller
        self._text = text
        _textController = StateObject(
            wrappedValue: AgentTextInputController(
                text: text,
                sharedState: controller.state
            )
        )
    }

    var body: some View {
        KeyboardView(
            services: controller.services,
            buttonContent: { item in
                item.view
            },
            buttonView: { item in
                item.view
            },
            collapsedView: { item in
                item.view
            },
            emojiKeyboard: { item in
                item.view
            },
            toolbar: { item in
                AnyView(
                    AnimatedAutocompleteToolbar(
                        suggestions: controller.state.autocompleteContext.suggestions,
                        onSelect: { suggestion in
                            textController.replaceLastWord(with: suggestion.text, addTrailingSpace: true)
                        },
                        onAgentTap: {}
                    )
                )
            }
        )
        .keyboardInputToolbarDisplayMode(.automatic)
        .autocompleteToolbarStyle(.agosecStandard)
        .ignoresSafeArea(.container, edges: .top)
        .onAppear {
            previousReturnKeyOverride = controller.state.keyboardContext.returnKeyTypeOverride
            controller.services.actionHandler = AgentKeyboardActionHandler(
                controller: textController,
                onReturn: {
                    NotificationCenter.default.post(
                        name: Notification.Name("AgentChatSend"),
                        object: nil
                    )
                }
            )
            controller.state.keyboardContext.returnKeyTypeOverride = .send
        }
        .onDisappear {
            controller.services.actionHandler = KeyboardAction.StandardActionHandler.standard(for: controller)
            controller.state.keyboardContext.returnKeyTypeOverride = previousReturnKeyOverride
        }
        .onChange(of: text) { _ in
            textController.syncCursorToEnd()
            updateAutocomplete()
        }
    }

    private func updateAutocomplete() {
        let input = text
        Task { [services = controller.services, state = controller.state] in
            do {
                let result = try await services.autocompleteService.autocomplete(input)
                await MainActor.run {
                    state.autocompleteContext.update(with: result)
                }
            } catch {
                await MainActor.run {
                    state.autocompleteContext.update(with: error)
                }
            }
        }
    }
}
