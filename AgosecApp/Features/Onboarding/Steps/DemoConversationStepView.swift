import SwiftUI
import UIComponents

struct DemoConversationStepView: View {
    let onComplete: () -> Void
    @State private var showKeyboardDemo = false
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var messageAnimations: [Bool] = [false, false, false]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(geometry.size.height * 0.04, 20))
                    
                    // Animated icon with modern design
                    ZStack {
                    // Animated glow rings
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
                                lineWidth: 2
                            )
                            .frame(width: 100 + CGFloat(index) * 16, height: 100 + CGFloat(index) * 16)
                            .scaleEffect(1.0 + CGFloat(index) * 0.1)
                            .opacity(iconOpacity * (1.0 - Double(index) * 0.3))
                    }
                    
                    // Icon background with glassmorphism
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
                            .frame(width: 90, height: 90)
                        
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
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 36, weight: .medium))
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
                .padding(.bottom, 20)
                
                // Title
                Text("Try It Out")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Subtitle
                Text("See how Agosec helps you communicate smarter")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Demo conversation
                conversationPreview
                    .padding(.top, 20)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                    Spacer(minLength: 16)
                    
                    // Buttons
                    VStack(spacing: 14) {
                        ModernActionButton(
                            title: "Try Demo",
                            icon: "keyboard",
                            action: { showKeyboardDemo = true }
                        )
                        
                        ModernActionButton(
                            title: "Get Started",
                            icon: "arrow.right",
                            style: .secondary,
                            action: onComplete
                        )
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 80) // Account for page indicator
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
        }
        .sheet(isPresented: $showKeyboardDemo) {
            KeyboardDemoView()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private var conversationPreview: some View {
        VStack(spacing: 12) {
            // Incoming message
            MessageBubble(
                text: "Hey! Can you help me draft a professional email?",
                isUser: false,
                isVisible: messageAnimations[0]
            )
            
            // User message
            MessageBubble(
                text: "Sure! I'll help you write it.",
                isUser: true,
                isVisible: messageAnimations[1]
            )
            
            // AI suggestion hint
            if messageAnimations[2] {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.purple)
                    
                    Text("Agosec suggests contextual responses")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .padding(.horizontal, 24)
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
    
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }
            
            Text(text)
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(isUser ? .white : Color(red: 0.9, green: 0.9, blue: 0.95))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
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
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(isUser ? 0 : 0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            if !isUser { Spacer(minLength: 60) }
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
                        
                        Text("Tap the globe icon on your keyboard to switch")
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
