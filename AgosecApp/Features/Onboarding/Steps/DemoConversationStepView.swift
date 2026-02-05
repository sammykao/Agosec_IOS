import SwiftUI
import UIComponents

struct DemoConversationStepView: View {
    let onComplete: () -> Void
    @State private var showKeyboardDemo = false
    @State private var showScreenshotPrompt = false
    @State private var hasTriedDemo = false
    @State private var shouldCompleteAfterDemo = false
    @State private var messageAnimations: [Bool] = [false, false, false]

    var body: some View {
        NavigationStack {
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
                                action: {
                                    shouldCompleteAfterDemo = true
                                    showScreenshotPrompt = true
                                }
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
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showScreenshotPrompt) {
                ScreenshotPromptView(onConfirm: {
                    showKeyboardDemo = true
                })
            }
            .navigationDestination(isPresented: $showKeyboardDemo) {
                KeyboardDemoView(onDismiss: {
                    if shouldCompleteAfterDemo {
                        shouldCompleteAfterDemo = false
                        onComplete()
                    } else {
                        hasTriedDemo = true
                    }
                })
            }
        }
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
    let onDismiss: (() -> Void)?
    @State private var inputText = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        messageBubble(text: "Hey! Can you help me draft a professional email?", isUser: false)
                        messageBubble(text: "Sure — what's the purpose and who is it for?", isUser: true)
                        messageBubble(text: "It's to a recruiter about a backend role.", isUser: false)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

                inputBar
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .onDisappear {
            onDismiss?()
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(red: 0.55, green: 0.78, blue: 0.97))

            TextField("iMessage", text: $inputText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(red: 0.16, green: 0.16, blue: 0.17))
                .foregroundColor(.white)
                .cornerRadius(18)

            Button(action: {}) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.27, green: 0.85, blue: 0.46))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(red: 0.08, green: 0.08, blue: 0.09))
    }

    private func messageBubble(text: String, isUser: Bool) -> some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            Text(text)
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isUser
                            ? Color(red: 0.19, green: 0.55, blue: 1.0)
                            : Color(red: 0.22, green: 0.22, blue: 0.23)
                        )
                )

            if !isUser { Spacer(minLength: 40) }
        }
    }
}

struct ScreenshotPromptView: View {
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("iMessage Demo")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    messageBubble(text: "Take a screenshot of this screen.", isUser: false)
                        .padding(.horizontal, 24)
                }

                Spacer()

                Button(action: onConfirm) {
                    Text("I Took a Screenshot")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .padding(.top, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("Messages")
    }

    private func messageBubble(text: String, isUser: Bool) -> some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            Text(text)
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.22, green: 0.22, blue: 0.23))
                )

            if !isUser { Spacer(minLength: 40) }
        }
    }
}
