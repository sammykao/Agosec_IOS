import SwiftUI

struct DemoConversationStepView: View {
    let onComplete: () -> Void
    @State private var showKeyboardDemo = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "message.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Try It Out")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("See how Agosec Keyboard works in a sample conversation")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            DemoMessageBubble(
                text: "Hi! How are you doing today?",
                isUser: false
            )
            
            DemoMessageBubble(
                text: "I'm doing great! Just working on the new app.",
                isUser: true
            )
            
            Spacer()
            
            VStack(spacing: 12) {
                ActionButton(title: "Open Demo", action: { showKeyboardDemo = true })
                ActionButton(title: "Continue", action: onComplete, style: .secondary)
            }
            .padding(.horizontal)
        }
        .padding()
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