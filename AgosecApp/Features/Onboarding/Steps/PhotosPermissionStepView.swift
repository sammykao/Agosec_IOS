import SwiftUI
import PhotosUI
import UIComponents

struct PhotosPermissionStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var photosStatus: PHAuthorizationStatus = .notDetermined
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var shimmerOffset: CGFloat = -200
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: geometry.size.height * 0.08)
                
                // Animated icon with photo stack effect
                ZStack {
                    // Background photos stack
                    ForEach(0..<2) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1 - Double(index) * 0.03))
                            .frame(width: 70 - CGFloat(index) * 8, height: 70 - CGFloat(index) * 8)
                            .offset(x: CGFloat(index) * 8, y: CGFloat(index) * -8)
                            .rotationEffect(.degrees(Double(index) * -5))
                    }
                    
                    // Main icon container
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "photo.stack.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .padding(.bottom, 32)
                
                // Title
                Text("Photo Access")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Subtitle
                Text("Allow access to screenshots for AI context awareness")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .padding(.top, 12)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Info card
                infoCard
                    .padding(.top, 32)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                Spacer()
                
                // Buttons based on status
                buttonsForStatus
                    .padding(.horizontal, 28)
                    .padding(.bottom, 100)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
            }
        }
        .onAppear {
            startAnimations()
            checkPhotoStatus()
        }
    }
    
    private var infoCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Context")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text("AI can understand screenshots to help you respond")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.5))
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack(spacing: 14) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Optional Feature")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text("You can skip this and enable later in settings")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.5))
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private var buttonsForStatus: some View {
        VStack(spacing: 14) {
            switch photosStatus {
            case .notDetermined:
                ModernActionButton(
                    title: "Allow Photo Access",
                    icon: "photo.fill",
                    action: requestPhotoAccess
                )
                
                ModernActionButton(
                    title: "Skip for Now",
                    style: .secondary,
                    action: onNext
                )
                
            case .authorized, .limited:
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    
                    Text("Photo access granted")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                }
                .padding(.bottom, 8)
                
                ModernActionButton(
                    title: "Continue",
                    icon: "arrow.right",
                    action: onNext
                )
                
            case .denied, .restricted:
                ModernActionButton(
                    title: "Open Settings",
                    icon: "gear",
                    action: openSettings
                )
                
                ModernActionButton(
                    title: "Skip for Now",
                    style: .secondary,
                    action: onNext
                )
                
            @unknown default:
                ModernActionButton(
                    title: "Continue",
                    icon: "arrow.right",
                    action: onNext
                )
            }
        }
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
    }
    
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    photosStatus = status
                }
            }
        }
    }
    
    private func checkPhotoStatus() {
        photosStatus = PHPhotoLibrary.authorizationStatus()
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
