import SwiftUI
import UIComponents

struct DemoConversationStepView: View {
    let onComplete: () -> Void
    @State private var showKeyboardDemo = false
    @State private var hasTriedDemo = false
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var messageAnimations: [Bool] = [false, false, false]
    
    var body: some View {
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.width < 380
            let iconSize = min(geometry.size.width * 0.22, 90)
            let ringBaseSize = min(geometry.size.width * 0.25, 100)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(geometry.size.height * 0.12, 60))
                    
                    // Animated icon with modern design (responsive)
                    ZStack {
                        // Animated glow rings (responsive)
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
                                    lineWidth: isSmallScreen ? 1.5 : 2
                                )
                                .frame(width: ringBaseSize + CGFloat(index) * 16, height: ringBaseSize + CGFloat(index) * 16)
                                .scaleEffect(1.0 + CGFloat(index) * 0.1)
                                .opacity(iconOpacity * (1.0 - Double(index) * 0.3))
                        }
                        
                        // Icon background with glassmorphism (responsive)
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
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .padding(.bottom, min(geometry.size.height * 0.025, 20))
                    
                    // Title (responsive)
                    Text("Try It Out")
                        .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    // Subtitle (responsive)
                    Text("See how Agosec helps you communicate smarter")
                        .font(.system(size: min(geometry.size.width * 0.043, 17), weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, geometry.size.width * 0.1)
                        .padding(.top, min(geometry.size.height * 0.012, 10))
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    // Demo conversation (responsive)
                    conversationPreview(in: geometry)
                        .padding(.top, min(geometry.size.height * 0.025, 20))
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    Spacer(minLength: 16)
                    
                    // Buttons (responsive)
                    VStack(spacing: isSmallScreen ? 10 : 14) {
                        if hasTriedDemo {
                            ModernActionButton(
                                title: "Continue",
                                icon: "arrow.right",
                                action: onComplete
                            )
                            
                            Button(action: { showKeyboardDemo = true }) {
                                Text("Try Demo Again")
                                    .font(.system(size: isSmallScreen ? 14 : 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                            }
                        } else {
                            ModernActionButton(
                                title: "Try Demo",
                                icon: "keyboard",
                                action: { showKeyboardDemo = true }
                            )
                            
                            Text("Complete the demo to continue")
                                .font(.system(size: isSmallScreen ? 12 : 13, weight: .regular))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.07)
                    .padding(.bottom, 80) // Account for page indicator
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
        }
        .sheet(isPresented: $showKeyboardDemo, onDismiss: {
            hasTriedDemo = true
        }) {
            KeyboardDemoView()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func conversationPreview(in geometry: GeometryProxy) -> some View {
        let isSmallScreen = geometry.size.width < 380
        let fontSize = min(geometry.size.width * 0.04, 16)
        let hintFontSize = min(geometry.size.width * 0.035, 14)
        
        return VStack(spacing: isSmallScreen ? 10 : 12) {
            // Incoming message
            MessageBubble(
                text: "Hey! Can you help me draft a professional email?",
                isUser: false,
                isVisible: messageAnimations[0],
                fontSize: fontSize
            )
            
            // User message
            MessageBubble(
                text: "Sure! I'll help you write it.",
                isUser: true,
                isVisible: messageAnimations[1],
                fontSize: fontSize
            )
            
            // AI suggestion hint
            if messageAnimations[2] {
                HStack(spacing: isSmallScreen ? 6 : 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: hintFontSize, weight: .medium))
                        .foregroundColor(.purple)
                    
                    Text("Agosec suggests contextual responses")
                        .font(.system(size: hintFontSize, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                }
                .padding(.top, isSmallScreen ? 6 : 8)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .padding(.horizontal, geometry.size.width * 0.06)
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
        
        // Animate messages sequentially
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
                .padding(.horizontal, max(fontSize * 0.9, 12))
                .padding(.vertical, max(fontSize * 0.7, 10))
                .background(
                    RoundedRectangle(cornerRadius: max(fontSize * 1.1, 16))
                        .fill(
                            isUser ?
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: max(fontSize * 1.1, 16))
                        .stroke(Color.white.opacity(isUser ? 0 : 0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            if !isUser { Spacer(minLength: 40) }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }
}

// MARK: - Keyboard Demo View

struct KeyboardDemoView: View {
    @State private var text = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                Color(red: 0.08, green: 0.08, blue: 0.12)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Demo chat area
                    VStack(spacing: 16) {
                        Image(systemName: "keyboard.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                        
                        Text("Switch to Agosec Keyboard")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))
                        
                        Text("Long-press the spacebar or use the keyboard switcher to switch keyboards")
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // Text field
                    TextField("Type something...", text: $text)
                        .font(.system(size: 17, design: .default))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            .navigationTitle("Try Agosec")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                // Configure dark navigation bar for iOS 15+
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
            }
        }
    }
}
