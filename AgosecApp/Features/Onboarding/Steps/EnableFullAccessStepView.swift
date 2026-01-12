import SwiftUI
import UIComponents

struct EnableFullAccessStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var hasFullAccess = false
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: min(geometry.size.height * 0.03, 24)) {
                    Spacer(minLength: max(geometry.size.height * 0.1, 40))
                    
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: min(geometry.size.width * 0.2, 80)))
                        .foregroundColor(.orange)
                    
                    Text("Allow Full Access")
                        .font(.system(size: min(geometry.size.width * 0.06, 24), weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 16) {
                        Text("Full Access is required for:")
                            .font(.system(size: min(geometry.size.width * 0.04, 16)))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            AccessFeatureRow(text: "AI-powered responses")
                            AccessFeatureRow(text: "Network connectivity")
                            AccessFeatureRow(text: "Backend communication")
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InstructionStep(number: 1, text: "Tap Open Settings")
                        InstructionStep(number: 2, text: "Tap Agosec Keyboard")
                        InstructionStep(number: 3, text: "Enable 'Allow Full Access'")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, max(geometry.size.width * 0.1, 24))
                    
                    Spacer(minLength: max(geometry.size.height * 0.1, 40))
                    
                    VStack(spacing: 12) {
                        ActionButton(title: "Open Settings", action: openSettings)
                        
                        if hasFullAccess {
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
            checkFullAccessStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            checkFullAccessStatus()
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func checkFullAccessStatus() {
        hasFullAccess = permissionsService.hasFullAccess
    }
}

struct AccessFeatureRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
                .font(.system(size: 16))
        }
    }
}