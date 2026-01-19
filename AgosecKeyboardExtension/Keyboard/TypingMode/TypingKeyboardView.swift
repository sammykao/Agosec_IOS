import SwiftUI
import UIKit

struct TypingKeyboardView: View {
    let onAgentModeTapped: () -> Void
    let onKeyTapped: (Key) -> Void
    let inputViewController: UIInputViewController?
    let textDocumentProxy: UITextDocumentProxy?
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isShiftEnabled = false
    @State private var isSymbolMode = false
    @State private var isEmojiMode = false
    @State private var suggestions: [String] = []
    @State private var currentText: String = ""
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    
    private let autocompleteService = AutocompleteService()
    
    // iOS keyboard dimensions
    private let keyHeight: CGFloat = 45  // Slightly taller
    private let rowSpacing: CGFloat = 10
    private let keySpacing: CGFloat = 5
    
    var body: some View {
        VStack(spacing: 0) {
            if !isEmojiMode {
                // Suggestion bar
                suggestionBar
                    .frame(height: 44)
                    .background(suggestionBarBackgroundColor)
                    .frame(maxWidth: .infinity)
                
                // Keyboard rows
                VStack(spacing: rowSpacing) {
                    // Row 1: QWERTYUIOP or numbers (10 keys)
                    keyRow(keys: keyboardLayout.rows[0])
                    
                    // Row 2: ASDFGHJKL (9 keys - centered)
                    keyRow(keys: keyboardLayout.rows[1], centered: true)
                    
                    // Row 3: Shift + ZXCVBNM + Backspace (with wide keys)
                    row3WithWideKeys(keys: keyboardLayout.rows[2])
                    
                    // Row 4: 123, emoji, space, return
                    bottomRow(keys: keyboardLayout.rows[3])
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity)
            } else {
                EmojiKeyboardView(
                    onEmojiSelected: { emoji in
                        handleEmojiSelected(emoji)
                    },
                    onBackToAlphabet: {
                        isEmojiMode = false
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(keyboardBackgroundColor)
        .onAppear {
            updateTextContext()
            updateSuggestions()
        }
        .onChange(of: currentText) { _ in
            updateSuggestions()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("KeyboardTextDidChange"))) { _ in
            updateTextContext()
            updateSuggestions()
        }
    }
    
    // MARK: - Key Rows
    
    private func keyRow(keys: [Key], centered: Bool = false) -> some View {
        HStack(spacing: keySpacing) {
            if centered {
                Spacer(minLength: 0)
            }
            
            ForEach(keys, id: \.id) { key in
                KeyButton(
                    key: key,
                    height: keyHeight,
                    colorScheme: colorScheme,
                    isSpecial: key.type == .shift || key.type == .backspace
                ) {
                    handleKeyPress(key)
                }
                .layoutPriority(1.0)
            }
            
            if centered {
                Spacer(minLength: 0)
            }
        }
        .frame(height: keyHeight)
        .frame(maxWidth: .infinity)
    }
    
    private func row3WithWideKeys(keys: [Key]) -> some View {
        HStack(spacing: keySpacing) {
            ForEach(keys, id: \.id) { key in
                KeyButton(
                    key: key,
                    height: keyHeight,
                    colorScheme: colorScheme,
                    isSpecial: key.type == .shift || key.type == .backspace
                ) {
                    handleKeyPress(key)
                }
                .layoutPriority(key.type == .shift || key.type == .backspace ? 1.5 : 1.0)
            }
        }
        .frame(height: keyHeight)
        .frame(maxWidth: .infinity)
    }
    
    private func bottomRow(keys: [Key]) -> some View {
        HStack(spacing: keySpacing) {
            // 123/ABC button
            if let symbolKey = keys.first(where: { $0.type == .symbol }) {
                KeyButton(
                    key: symbolKey,
                    height: keyHeight,
                    colorScheme: colorScheme,
                    isSpecial: true,
                    fixedWidth: 48
                ) {
                    handleKeyPress(symbolKey)
                }
            }
            
            // Emoji button
            if let emojiKey = keys.first(where: { $0.type == .emoji }) {
                KeyButton(
                    key: emojiKey,
                    height: keyHeight,
                    colorScheme: colorScheme,
                    isSpecial: true,
                    fixedWidth: 48
                ) {
                    handleKeyPress(emojiKey)
                }
            }
            
            // Space bar (flexible - takes remaining space)
            if let spaceKey = keys.first(where: { $0.type == .space }) {
                KeyButton(
                    key: spaceKey,
                    height: keyHeight,
                    colorScheme: colorScheme,
                    isSpecial: false
                ) {
                    handleKeyPress(spaceKey)
                }
                .layoutPriority(2.0)
            }
            
            // Return button
            if let returnKey = keys.first(where: { $0.type == .arrow }) {
                KeyButton(
                    key: returnKey,
                    height: keyHeight,
                    colorScheme: colorScheme,
                    isSpecial: true,
                    fixedWidth: 48
                ) {
                    handleKeyPress(returnKey)
                }
            }
        }
        .frame(height: keyHeight)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Suggestion Bar
    
    private var suggestionBar: some View {
        HStack(spacing: 12) {
            Button(action: onAgentModeTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                    Text("AI")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [Color.orange, Color.orange.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            
            SuggestionBarView(
                suggestions: suggestions,
                onSuggestionTapped: { suggestion in
                    handleSuggestionTapped(suggestion)
                }
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Colors
    
    private var keyboardBackgroundColor: Color {
        // Transparent background to match system keyboard window
        Color.clear
    }
    
    private var suggestionBarBackgroundColor: Color {
        // Transparent background to match system keyboard window
        Color.clear
    }
    
    // MARK: - Layout
    
    private var keyboardLayout: KeyboardLayout {
        isSymbolMode ? SymbolKeyboardLayout() : QWERTYKeyboardLayout(isShiftEnabled: isShiftEnabled)
    }
    
    // MARK: - Key Handling
    
    private func handleKeyPress(_ key: Key) {
        switch key.type {
        case .shift:
            isShiftEnabled.toggle()
        case .symbol:
            if isSymbolMode && key.value == "#+=" {
                isSymbolMode = false
            } else if key.value == "123" {
                isSymbolMode = true
            } else if key.value == "ABC" {
                isSymbolMode = false
            }
        case .emoji:
            isEmojiMode = true
        case .arrow:
            onKeyTapped(key)
            updateTextContext()
        default:
            onKeyTapped(key)
            if isShiftEnabled && key.type == .character {
                isShiftEnabled = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateTextContext()
            }
        }
    }
    
    private func handleSuggestionTapped(_ suggestion: String) {
        guard let proxy = textDocumentProxy else { return }
        
        let wordRange = autocompleteService.findCurrentWordRange(in: currentText, at: selectedRange.location)
        
        if wordRange.location != NSNotFound {
            for _ in 0..<wordRange.length {
                proxy.deleteBackward()
            }
        }
        
        proxy.insertText(suggestion + " ")
        updateTextContext()
    }
    
    private func handleEmojiSelected(_ emoji: String) {
        textDocumentProxy?.insertText(emoji)
        updateTextContext()
    }
    
    private func updateTextContext() {
        guard let proxy = textDocumentProxy else { return }
        
        let beforeText = proxy.documentContextBeforeInput ?? ""
        let afterText = proxy.documentContextAfterInput ?? ""
        currentText = beforeText + afterText
        selectedRange = NSRange(location: beforeText.count, length: 0)
    }
    
    private func updateSuggestions() {
        let newSuggestions = autocompleteService.getSuggestions(for: currentText, selectedRange: selectedRange)
        DispatchQueue.main.async {
            suggestions = newSuggestions
        }
    }
}

// MARK: - Key Button

struct KeyButton: View {
    let key: Key
    let height: CGFloat
    let colorScheme: ColorScheme
    var isSpecial: Bool = false
    var fixedWidth: CGFloat? = nil
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            ZStack {
                // Glassmorphic key background - darker and sleeker
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        // Darker glass gradient
                        LinearGradient(
                            colors: [
                                keyBackgroundColor.opacity(0.9),
                                keyBackgroundColor.opacity(0.75),
                                keyBackgroundColor.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Glass border with gradient
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(colorScheme == .dark ? 0.15 : 0.4),
                                        Color.white.opacity(0.05),
                                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .overlay(
                        // Top highlight for glass depth
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isSpecial ? 0.15 : 0.25),
                                        Color.white.opacity(0.08),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    )
                    .overlay(
                        // Subtle inner shadow for depth
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                                lineWidth: 0.5
                            )
                            .blur(radius: 0.5)
                    )
                    .shadow(color: keyShadowColor, radius: keyShadowRadius, x: 0, y: keyShadowY)
                    .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 0.5)
                
                keyContent
            }
            .frame(height: height)
            .frame(minWidth: minKeyWidth)
            .frame(idealWidth: fixedWidth)
            .frame(maxWidth: fixedWidth ?? .infinity)
        }
        .buttonStyle(KeyPressButtonStyle(isPressed: $isPressed))
    }
    
    
    @ViewBuilder
    private var keyContent: some View {
        if let imageName = key.imageName {
            Image(systemName: imageName)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(keyTextColor)
        } else if key.type == .emoji {
            Text(key.displayValue)
                .font(.system(size: 22))
        } else {
            Text(key.displayValue)
                .font(.system(size: fontSize, weight: fontWeight))
                .foregroundColor(keyTextColor)
        }
    }
    
    // MARK: - Sizing
    
    private var minKeyWidth: CGFloat {
        switch key.type {
        case .character: return 34
        case .space: return 140
        case .shift, .backspace: return 50
        default: return 42
        }
    }
    
    // MARK: - Colors (Lighter, Glass-like)
    
    private var keyBackgroundColor: Color {
        if isSpecial {
            return colorScheme == .dark
                ? Color(red: 0.30, green: 0.30, blue: 0.32)  // Lighter
                : Color(red: 0.62, green: 0.64, blue: 0.67)  // Lighter gray
        } else {
            return colorScheme == .dark
                ? Color(red: 0.40, green: 0.40, blue: 0.42)  // Lighter
                : Color(red: 0.72, green: 0.74, blue: 0.77)  // Lighter gray (glass-like)
        }
    }
    
    private var keyPressedColor: Color {
        if isSpecial {
            return colorScheme == .dark
                ? Color(red: 0.40, green: 0.40, blue: 0.42)  // Lighter
                : Color(red: 0.55, green: 0.57, blue: 0.60)  // Lighter
        } else {
            return colorScheme == .dark
                ? Color(red: 0.50, green: 0.50, blue: 0.52)  // Lighter
                : Color(red: 0.78, green: 0.80, blue: 0.83)  // Lighter
        }
    }
    
    private var keyShadowColor: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.5)
            : Color.black.opacity(0.25)
    }
    
    private var keyShadowRadius: CGFloat {
        colorScheme == .dark ? 3 : 2
    }
    
    private var keyShadowY: CGFloat {
        colorScheme == .dark ? 2 : 1.5
    }
    
    private var keyTextColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            // Slightly lighter text since keys are lighter now
            return Color(red: 0.20, green: 0.20, blue: 0.23)
        }
    }
    
    private var fontSize: CGFloat {
        switch key.type {
        case .character: return 24
        case .space: return 16
        case .symbol: return 16
        default: return 16
        }
    }
    
    private var iconSize: CGFloat {
        switch key.type {
        case .backspace: return 22
        case .shift: return 19
        case .arrow: return 17
        default: return 18
        }
    }
    
    private var fontWeight: Font.Weight {
        key.type == .character ? .regular : .medium
    }
}

// MARK: - Button Style

struct KeyPressButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}
