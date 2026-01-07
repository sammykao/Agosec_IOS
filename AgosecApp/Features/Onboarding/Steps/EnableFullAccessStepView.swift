import SwiftUI

struct EnableFullAccessStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var hasFullAccess = false
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.open.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Allow Full Access")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                Text("Full Access is required for:")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 8) {
                    AccessFeatureRow(text: "AI-powered responses")
                    AccessFeatureRow(text: "Network connectivity")
                    AccessFeatureRow(text: "Backend communication")
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionStep(number: 1, text: "Tap Open Settings")
                InstructionStep(number: 2, text: "Tap Agosec Keyboard")
                InstructionStep(number: 3, text: "Enable 'Allow Full Access'")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
            VStack(spacing: 12) {
                ActionButton(title: "Open Settings", action: openSettings)
                
                if hasFullAccess {
                    ActionButton(title: "Continue", action: onNext)
                }
            }
            .padding(.horizontal)
        }
        .padding()
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