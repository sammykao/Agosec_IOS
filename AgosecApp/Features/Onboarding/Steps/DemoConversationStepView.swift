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
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: geometry.size.height * 0.06)
                
                // Animated icon
                ZStack {
                    // Glow
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                    
                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.2), Color.purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .padding(.bottom, 28)
                
                // Title
                Text("Try It Out")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Subtitle
                Text("See how Agosec helps you communicate smarter")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Demo conversation
                conversationPreview
                    .padding(.top, 28)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                Spacer()
                
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
                .padding(.bottom, 100)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
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
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
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
                .foregroundColor(isUser ? .white : Color(red: 0.2, green: 0.2, blue: 0.25))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            isUser ?
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(red: 0.94, green: 0.94, blue: 0.96), Color(red: 0.92, green: 0.92, blue: 0.94)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            
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
            VStack(spacing: 0) {
                Spacer()
                
                // Demo chat area
                VStack(spacing: 16) {
                    Image(systemName: "keyboard.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                    
                    Text("Switch to Agosec Keyboard")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text("Tap the globe icon on your keyboard to switch")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Text field
                TextField("Type something...", text: $text)
                    .font(.system(size: 17, design: .default))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .navigationTitle("Try Agosec")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}
