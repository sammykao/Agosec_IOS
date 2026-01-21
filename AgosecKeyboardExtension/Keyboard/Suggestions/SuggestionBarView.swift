import SwiftUI
import UIKit

struct SuggestionBarView: View {
    let suggestions: [String]
    let onSuggestionTapped: (String) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if suggestions.isEmpty {
            // Empty state - show subtle placeholder
            Color.clear
                .frame(maxWidth: .infinity)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        SuggestionButton(
                            text: suggestion,
                            action: {
                                onSuggestionTapped(suggestion)
                            }
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

struct SuggestionButton: View {
    let text: String
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator.safeImpact(.light)
            action()
        }) {
            Text(text)
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 0.5)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    private var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(red: 0.4, green: 0.4, blue: 0.42)
        } else {
            return Color.white
        }
    }
    
    private var borderColor: Color {
        if colorScheme == .dark {
            return Color(red: 0.3, green: 0.3, blue: 0.32)
        } else {
            return Color(red: 0.85, green: 0.85, blue: 0.85)
        }
    }
}
