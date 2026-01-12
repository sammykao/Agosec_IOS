import SwiftUI
import UIComponents

struct EnableKeyboardStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var isKeyboardEnabled = false
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: min(geometry.size.height * 0.03, 24)) {
                    Spacer(minLength: max(geometry.size.height * 0.1, 40))
                    
                    Image(systemName: "gear")
                        .font(.system(size: min(geometry.size.width * 0.2, 80)))
                        .foregroundColor(.blue)
                    
                    Text("Enable Keyboard")
                        .font(.system(size: min(geometry.size.width * 0.06, 24), weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    Text("Add Agosec Keyboard to your keyboards in Settings")
                        .font(.system(size: min(geometry.size.width * 0.04, 16)))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InstructionStep(number: 1, text: "Tap Open Settings")
                        InstructionStep(number: 2, text: "Tap Keyboards")
                        InstructionStep(number: 3, text: "Enable Agosec Keyboard")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, max(geometry.size.width * 0.1, 24))
                    
                    Spacer(minLength: max(geometry.size.height * 0.1, 40))
                    
                    VStack(spacing: 12) {
                        ActionButton(title: "Open Settings", action: openSettings)
                        
                        if isKeyboardEnabled {
                            ActionButton(title: "Continue", action: onNext)
                        }
                    }
                    .padding(.horizontal, max(geometry.size.width * 0.1, 24))
                    .padding(.bottom, 40)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear {
            checkKeyboardStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            checkKeyboardStatus()
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func checkKeyboardStatus() {
        isKeyboardEnabled = permissionsService.isKeyboardExtensionEnabled
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 24, height: 24)
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Text(text)
                .font(.system(size: 16))
            
            Spacer()
        }
    }
}