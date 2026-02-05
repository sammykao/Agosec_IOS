import SwiftUI
import KeyboardKit

struct KeyboardKitTypingView: View {
    let controller: KeyboardInputViewController
    @ObservedObject private var autocompleteContext: AutocompleteContext

    init(controller: KeyboardInputViewController) {
        self.controller = controller
        self._autocompleteContext = ObservedObject(
            wrappedValue: controller.state.autocompleteContext
        )
    }

    var body: some View {
        // Standard KeyboardKit keyboard view - use default implementation
        // KeyboardView automatically uses controller's state and services from environment
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
                        suggestions: autocompleteContext.suggestions,
                        onSelect: item.autocompleteAction,
                        onAgentTap: {
                            NotificationCenter.default.post(
                                name: Notification.Name("KeyboardOpenAgentMode"),
                                object: nil
                            )
                        }
                    )
                )
            }
        )
        .keyboardInputToolbarDisplayMode(.automatic)
        .autocompleteToolbarStyle(.agosecStandard)
        .ignoresSafeArea(.container, edges: .top)
        .animation(.easeInOut(duration: 0.15), value: autocompleteContext.suggestions)
    }
}

extension Autocomplete.ToolbarStyle {
    static var agosecStandard: Autocomplete.ToolbarStyle {
        .init(height: 36, padding: 0)
    }
}

struct AnimatedAutocompleteToolbar: View {
    let suggestions: [Autocomplete.Suggestion]
    let onSelect: (Autocomplete.Suggestion) -> Void
    let onAgentTap: () -> Void

    @Environment(\.autocompleteToolbarStyle) private var toolbarStyle
    @State private var isAgentPressed = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(suggestions.enumerated()), id: \.element) { index, suggestion in
                AnimatedAutocompleteToolbarItem(
                    suggestion: suggestion,
                    onSelect: { onSelect(suggestion) }
                )

                if index < suggestions.count - 1 {
                    Autocomplete.ToolbarSeparator()
                }
            }
            Autocomplete.ToolbarSeparator()
            Button(action: onAgentTap) {
                Image("agosec_logo")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .frame(width: 40, height: 36)
                    .background(
                        Circle()
                            .fill(Color.black)
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .scaleEffect(isAgentPressed ? 0.9 : 1.0)
            .opacity(isAgentPressed ? 0.75 : 1.0)
            .animation(.easeOut(duration: 0.12), value: isAgentPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isAgentPressed { isAgentPressed = true }
                    }
                    .onEnded { _ in
                        isAgentPressed = false
                    }
            )
        }
        .frame(height: toolbarStyle.height)
        .padding(.horizontal, toolbarStyle.padding)
    }
}

struct AnimatedAutocompleteToolbarItem: View {
    let suggestion: Autocomplete.Suggestion
    let onSelect: () -> Void

    @State private var isPressed = false
    @State private var flashOnTap = false

    var body: some View {
        Button(action: onSelect) {
            Autocomplete.ToolbarItem(suggestion: suggestion)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(flashOnTap ? 0.18 : 0.0))
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .opacity(isPressed ? 0.7 : 1.0)
        .animation(.easeOut(duration: 0.12), value: isPressed)
        .animation(.easeOut(duration: 0.16), value: flashOnTap)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in
                    isPressed = false
                    flashOnTap = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        flashOnTap = false
                    }
                }
        )
    }
}
