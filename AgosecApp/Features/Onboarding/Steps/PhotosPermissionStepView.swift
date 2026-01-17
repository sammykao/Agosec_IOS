import SwiftUI
import PhotosUI
import UIComponents

struct PhotosPermissionStepView: View {
    @State private var photosStatus: PHAuthorizationStatus = .notDetermined
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var shimmerOffset: CGFloat = -200
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.width < 380
            let iconSize = min(geometry.size.width * 0.22, 90)
            let ringBaseSize = min(geometry.size.width * 0.25, 100)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(geometry.size.height * 0.05, 24))
                    
                    // Animated icon with modern design (responsive)
                    ZStack {
                    // Animated glow rings (responsive)
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.4 - Double(index) * 0.2),
                                        Color.green.opacity(0.15 - Double(index) * 0.1)
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
                    
                    // Background photos stack (subtle, responsive)
                    let photoStackSize = min(geometry.size.width * 0.18, 75)
                    ForEach(0..<2) { index in
                        RoundedRectangle(cornerRadius: isSmallScreen ? 10 : 12)
                            .fill(Color.green.opacity(0.12 - Double(index) * 0.04))
                            .frame(width: photoStackSize - CGFloat(index) * 10, height: photoStackSize - CGFloat(index) * 10)
                            .offset(x: CGFloat(index) * 6, y: CGFloat(index) * -6)
                            .rotationEffect(.degrees(Double(index) * -4))
                            .opacity(iconOpacity * 0.6)
                    }
                    
                    // Main icon container with glassmorphism (responsive)
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.25),
                                        Color.green.opacity(0.12)
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
                                        Color.green.opacity(0.4),
                                        Color.green.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: iconSize, height: iconSize)
                        
                        Image(systemName: "photo.stack.fill")
                            .font(.system(size: min(geometry.size.width * 0.1, 40), weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .padding(.bottom, min(geometry.size.height * 0.03, 24))
                
                // Title (responsive)
                Text("Photo Access")
                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Subtitle (responsive)
                Text("Allow access to screenshots for AI context awareness")
                    .font(.system(size: min(geometry.size.width * 0.043, 17), weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.top, min(geometry.size.height * 0.015, 12))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                // Info card (responsive)
                infoCard(in: geometry)
                    .padding(.top, min(geometry.size.height * 0.03, 24))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                    Spacer(minLength: 16)
                    
                    // Buttons based on status (responsive)
                    buttonsForStatus(in: geometry)
                        .padding(.horizontal, geometry.size.width * 0.07)
                        .padding(.bottom, 80) // Account for page indicator
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear {
            startAnimations()
            checkPhotoStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Recheck status when returning from Settings
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                checkPhotoStatus()
            }
        }
    }
    
    private func infoCard(in geometry: GeometryProxy) -> some View {
        let isSmallScreen = geometry.size.width < 380
        let iconSize: CGFloat = isSmallScreen ? 18 : 20
        let titleSize: CGFloat = isSmallScreen ? 14 : 16
        let descSize: CGFloat = isSmallScreen ? 12 : 14
        let spacing: CGFloat = isSmallScreen ? 10 : 14
        
        return VStack(spacing: isSmallScreen ? 12 : 16) {
            HStack(spacing: spacing) {
                Image(systemName: "sparkles")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Context")
                        .font(.system(size: titleSize, weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))
                    
                    Text("AI can understand screenshots to help you respond")
                        .font(.system(size: descSize, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: spacing) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Required for Full Features")
                        .font(.system(size: titleSize, weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))
                    
                    Text("Photo access is needed for AI context awareness")
                        .font(.system(size: descSize, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
        }
        .padding(isSmallScreen ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, geometry.size.width * 0.06)
    }
    
    @ViewBuilder
    private func buttonsForStatus(in geometry: GeometryProxy) -> some View {
        let isSmallScreen = geometry.size.width < 380
        
        VStack(spacing: isSmallScreen ? 10 : 14) {
            switch photosStatus {
            case .notDetermined:
                ModernActionButton(
                    title: "Allow Photo Access",
                    icon: "photo.fill",
                    action: requestPhotoAccess
                )
                
                Text("Photo access is required to continue")
                    .font(.system(size: isSmallScreen ? 12 : 13, weight: .regular))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                
            case .authorized, .limited:
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: isSmallScreen ? 18 : 20))
                        .foregroundColor(.green)
                    
                    Text("Photo access granted")
                        .font(.system(size: isSmallScreen ? 14 : 16, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                }
                .padding(.bottom, 8)
                
                ModernActionButton(
                    title: "Continue",
                    icon: "arrow.right",
                    action: onNext
                )
                
            case .denied, .restricted:
                Text("Photo access was denied")
                    .font(.system(size: isSmallScreen ? 13 : 14, weight: .medium))
                    .foregroundColor(.orange)
                    .padding(.bottom, 4)
                
                ModernActionButton(
                    title: "Open Settings to Enable",
                    icon: "gear",
                    action: openSettings
                )
                
                Text("Enable photo access in Settings, then return here")
                    .font(.system(size: isSmallScreen ? 12 : 13, weight: .regular))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                    .multilineTextAlignment(.center)
                
            @unknown default:
                ModernActionButton(
                    title: "Allow Photo Access",
                    icon: "photo.fill",
                    action: requestPhotoAccess
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
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    photosStatus = status
                }
            }
        }
    }
    
    private func checkPhotoStatus() {
        photosStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
