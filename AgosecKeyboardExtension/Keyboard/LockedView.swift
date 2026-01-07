import SwiftUI

struct LockedView: View {
    let onSubscribeTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Keyboard Locked")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Text("Subscribe to unlock Agosec Keyboard")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("Get AI-powered typing assistance in all your apps")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                ActionButton(
                    title: "Open App to Subscribe",
                    action: onSubscribeTapped
                )
                
                Text("Or switch keyboards using the globe icon")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}