import SwiftUI
import UIComponents

struct DemoConversationStepView: View {
    let onComplete: () -> Void
    @State private var showKeyboardDemo = false
    @State private var hasTriedDemo = false
    @State private var messageAnimations: [Bool] = [false, false, false]

    var body: some View {
        OnboardingStepScaffold(
            isScrollable: true,
            topSpacing: { geometry in
                ResponsiveSystem.isShortScreen
                    ? max(geometry.size.height * 0.10, 50)
                    : max(geometry.size.height * 0.12, 60)
            },
            header: { geometry, state in
                let iconSize = ResponsiveSystem.value(
                    extraSmall: 75,
                    small: 82,
                    standard: min(geometry.size.width * 0.22, 90)
                )
                let ringBaseSize = ResponsiveSystem.value(
                    extraSmall: 85,
                    small: 92,
                    standard: min(geometry.size.width * 0.25, 100)
                )

                ZStack {
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.4 - Double(index) * 0.2),
                                        Color.purple.opacity(0.15 - Double(index) * 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: ResponsiveSystem.isSmallScreen ? 1.5 : 2
                            )
                            .frame(
                                width: ringBaseSize + CGFloat(index) * 16,
                                height: ringBaseSize + CGFloat(index) * 16
                            )
                            .scaleEffect(1.0 + CGFloat(index) * 0.1)
                            .opacity(state.headerOpacity * (1.0 - Double(index) * 0.3))
                    }

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.25),
                                        Color.purple.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: iconSize, height: iconSize)

                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.4),
                                        Color.purple.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: iconSize, height: iconSize)

                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: min(geometry.size.width * 0.09, 36), weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.purple, Color.purple.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .scaleEffect(state.headerScale)
                .opacity(state.headerOpacity)
                .padding(.bottom, min(geometry.size.height * 0.025, 20))
            },
            bodyContent: { geometry, _ in
                VStack(spacing: 0) {
                    Text("Try It Out")
                        .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("See how Agosec helps you communicate smarter")
                        .font(.system(size: min(geometry.size.width * 0.043, 17), weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, geometry.size.width * 0.1)
                        .padding(.top, min(geometry.size.height * 0.012, 10))

                    conversationPreview(in: geometry)
                        .padding(.top, min(geometry.size.height * 0.025, 20))
                }
            },
            footer: { geometry, _ in
                VStack(spacing: ResponsiveSystem.isSmallScreen ? 10 : 14) {
                    if hasTriedDemo {
                        ModernActionButton(
                            title: "Continue",
                            icon: "arrow.right",
                            action: onComplete
                        )

                        Button(
                            action: { showKeyboardDemo = true },
                            label: {
                                Text("Try Demo Again")
                                    .font(.system(size: ResponsiveSystem.isSmallScreen ? 14 : 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                            }
                        )
                    } else {
                        ModernActionButton(
                            title: "Try Demo",
                            icon: "keyboard",
                            action: { showKeyboardDemo = true }
                        )

                        Text("Complete the demo to continue")
                            .font(.system(size: ResponsiveSystem.isSmallScreen ? 12 : 13, weight: .regular))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.07)
            },
            onAppear: {
                startConversationAnimations()
            }
        )
        .sheet(
            isPresented: $showKeyboardDemo,
            onDismiss: {
                hasTriedDemo = true
            },
            content: {
                KeyboardDemoView()
            }
        )
    }

    private func conversationPreview(in geometry: GeometryProxy) -> some View {
        let fontSize = min(geometry.size.width * 0.04, 16)
        let hintFontSize = min(geometry.size.width * 0.035, 14)

        return VStack(spacing: ResponsiveSystem.isSmallScreen ? 10 : 12) {
            MessageBubble(
                text: "Hey! Can you help me draft a professional email?",
                isUser: false,
                isVisible: messageAnimations[0],
                fontSize: fontSize
            )

            MessageBubble(
                text: "Sure! I'll help you write it.",
                isUser: true,
                isVisible: messageAnimations[1],
                fontSize: fontSize
            )

            if messageAnimations[2] {
                HStack(spacing: ResponsiveSystem.isSmallScreen ? 6 : 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: hintFontSize, weight: .medium))
                        .foregroundColor(.purple)

                    Text("Agosec suggests contextual responses")
                        .font(.system(size: hintFontSize, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                }
                .padding(.top, ResponsiveSystem.isSmallScreen ? 6 : 8)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .padding(.horizontal, geometry.size.width * 0.06)
    }

    private func startConversationAnimations() {
        messageAnimations = [false, false, false]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                messageAnimations[0] = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                messageAnimations[1] = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                messageAnimations[2] = true
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let text: String
    let isUser: Bool
    let isVisible: Bool
    var fontSize: CGFloat = 16

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            Text(text)
                .font(.system(size: fontSize, weight: .regular, design: .default))
                .foregroundColor(isUser ? .white : Color(red: 0.9, green: 0.9, blue: 0.95))
                .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 14 : 16)
                .padding(.vertical, ResponsiveSystem.isSmallScreen ? 10 : 12)
                .background(
                    RoundedRectangle(cornerRadius: ResponsiveSystem.isSmallScreen ? 16 : 18)
                        .fill(isUser
                            ? LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.9),
                                    Color.purple.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: ResponsiveSystem.isSmallScreen ? 16 : 18)
                                .stroke(
                                    isUser
                                        ? Color.white.opacity(0.2)
                                        : Color.white.opacity(0.12),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: isUser ? Color.purple.opacity(0.25) : Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.9)
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isVisible)

            if !isUser { Spacer(minLength: 40) }
        }
    }
}

// MARK: - Keyboard Demo

struct KeyboardDemoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                TextField("Type here...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 24)

                Text("This is a lightweight demo of the chat experience.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Keyboard Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
