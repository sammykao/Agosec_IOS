import SwiftUI
import UIComponents

struct DemoConversationStepView: View {
    let onComplete: () -> Void
    @State private var showKeyboardDemo = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: min(geometry.size.height * 0.03, 24)) {
                    Spacer(minLength: max(geometry.size.height * 0.08, 30))
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: min(geometry.size.width * 0.2, 80)))
                        .foregroundColor(.purple)
                    
                    Text("Try It Out")
                        .font(.system(size: min(geometry.size.width * 0.06, 24), weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    Text("See how Agosec Keyboard works in a sample conversation")
                        .font(.system(size: min(geometry.size.width * 0.04, 16)))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 12) {
                        DemoMessageBubble(
                            text: "Hi! How are you doing today?",
                            isUser: false
                        )
                        
                        DemoMessageBubble(
                            text: "I'm doing great! Just working on the new app.",
                            isUser: true
                        )
                    }
                    .padding(.horizontal, max(geometry.size.width * 0.1, 24))
                    .padding(.top, 16)
                    
                    Spacer(minLength: max(geometry.size.height * 0.1, 40))
                    
                    VStack(spacing: 12) {
                        ActionButton(title: "Open Demo", action: { showKeyboardDemo = true })
                        ActionButton(title: "Continue", action: onComplete, style: .secondary)
                    }
                    .padding(.horizontal, max(geometry.size.width * 0.1, 24))
                    .padding(.bottom, 40)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .sheet(isPresented: $showKeyboardDemo) {
            KeyboardDemoView()
        }
    }
}

struct DemoMessageBubble: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(text)
                .padding(12)
                .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(16)
            
            if !isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

struct KeyboardDemoView: View {
    @State private var text = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                TextField("Try typing here...", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
                
                Text("Switch to Agosec Keyboard using the globe icon")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding()
            }
            .navigationTitle("Keyboard Demo")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}