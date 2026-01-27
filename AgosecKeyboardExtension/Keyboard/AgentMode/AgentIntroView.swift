import SwiftUI
import Photos
import SharedCore
import UIComponents

struct AgentIntroView: View {
    let onChoiceMade: (IntroChoice) -> Void
    
    init(onChoiceMade: @escaping (IntroChoice) -> Void) {
        self.onChoiceMade = onChoiceMade
    }
    
    @State private var showingPhotoPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var selectedAssetIdentifiers: [String] = []
    @State private var showingDeleteConfirmation = false
    @State private var photoAccessStatus: PHAuthorizationStatus = .notDetermined
    @State private var showingPhotoAccessError = false
    @State private var isLoadingImages = false
    @State private var loadingMessage = "Loading images..."
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var logoFloat: CGFloat = 0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ResponsiveSystem.value(
                    extraSmall: 8,
                    small: 10,
                    standard: 12
                )) {
                    headerSection
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .offset(y: logoFloat)
                    
                    choiceButtonsSection
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    tipsSection
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                }
                .padding(.horizontal, ResponsiveSystem.value(extraSmall: 16, small: 20, standard: 24))
                .padding(.top, ResponsiveSystem.value(
                    extraSmall: 10,
                    small: 12,
                    standard: 16
                ))
                .padding(.bottom, ResponsiveSystem.value(
                    extraSmall: 40,
                    small: 50,
                    standard: 60
                ))
                .frame(maxWidth: .infinity)
            }
            .background(Color.clear)
            .safeAreaInset(edge: .bottom) {
                // Extra bottom padding to prevent cutoff on short screens
                Color.clear.frame(height: ResponsiveSystem.value(
                    extraSmall: 30,
                    small: 40,
                    standard: 50
                ))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showingDeleteConfirmation {
                deleteConfirmationOverlay
            }
            
            if showingPhotoAccessError {
                photoAccessOverlay
            }
        }
        .onAppear {
            startAnimations()
            checkPhotoAccessStatus()
        }
        .loadingOverlay(isPresented: isLoadingImages, message: loadingMessage)
        .sheet(isPresented: $showingPhotoPicker, onDismiss: {
            // Delay notification to ensure keyboard view is stable
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Reset loading state when sheet is dismissed
                // This handles the case where user cancels the picker
                if isLoadingImages {
                    isLoadingImages = false
                }
                // Notify that photo selection has ended
                NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
            }
        }) {
            PhotoPicker(
                selectedImages: $selectedImages,
                onLoadingStarted: {
                    isLoadingImages = true
                    loadingMessage = "Loading images..."
                },
                onSelectionComplete: { images, assetIdentifiers in
                    // Delay to ensure sheet is fully dismissed and keyboard is stable
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isLoadingImages = false
                        selectedImages = images
                        selectedAssetIdentifiers = assetIdentifiers

                        if !images.isEmpty {
                            // Additional delay to ensure view is ready for alert presentation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showingDeleteConfirmation = true
                            }
                        } else {
                            // Notify that photo selection has ended
                            NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
                            toastManager.show(
                                "No images were selected",
                                type: .info,
                                duration: 3.0
                            )
                        }
                    }
                },
                onError: { error in
                    isLoadingImages = false
                    // Notify that photo selection has ended
                    NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
                    let message = ErrorMapper.userFriendlyMessage(from: error)
                    toastManager.show(message, type: .error, duration: 4.0)
                }
            )
        }
        // NOTE: .alert uses UIAlertController which is not available in keyboard extensions.
        // We render custom overlays instead to avoid extension crashes.
    }
    
    private func checkPhotoAccessStatus() {
        photoAccessStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    private func checkPhotoAccessAndShowPicker() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            // Notify that photo selection is starting
            NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionStarted"), object: nil)
            showingPhotoPicker = true
        case .denied, .restricted:
            showingPhotoAccessError = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    photoAccessStatus = newStatus
                    if newStatus == .authorized || newStatus == .limited {
                        // Notify that photo selection is starting
                        NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionStarted"), object: nil)
                        showingPhotoPicker = true
                    } else {
                        showingPhotoAccessError = true
                    }
                }
            }
        @unknown default:
            showingPhotoAccessError = true
        }
    }
    
    private func openSettings() {
        // Note: UIApplication.shared is not available in keyboard extensions
        // The user will need to manually go to Settings to enable photo access
    }

    private func handleUseAndDelete() {
        showingDeleteConfirmation = false

        // Make copies to avoid capture issues
        let imagesCopy = selectedImages
        let identifiersCopy = selectedAssetIdentifiers
        
        // Delay to ensure keyboard is stable before processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Notify that photo selection has ended before making choice
            NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
            
            // Call on main thread - ensure we're on main thread
            DispatchQueue.main.async {
                onChoiceMade(.useAndDeleteScreenshots(imagesCopy, identifiersCopy))
            }
        }
    }
    
    private func handleUseOnly() {
        showingDeleteConfirmation = false

        // Make copy to avoid capture issues
        let imagesCopy = selectedImages
        
        // Delay to ensure keyboard is stable before processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Notify that photo selection has ended before making choice
            NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
            
            // Call on main thread - ensure we're on main thread
            DispatchQueue.main.async {
                onChoiceMade(.useScreenshots(imagesCopy))
            }
        }
    }
    
    private func handleDeleteCancel() {
        showingDeleteConfirmation = false
        
        // Delay notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Notify that photo selection has ended
            NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
        }
    }
    
    private func handlePhotoAccessOpenSettings() {
        showingPhotoAccessError = false
        openSettings()
    }
    
    private func handlePhotoAccessSkip() {
        showingPhotoAccessError = false
        onChoiceMade(.continueWithoutContext)
    }
    
    
    private var headerSection: some View {
        let circleSize: CGFloat = ResponsiveSystem.value(extraSmall: 180, small: 200, standard: 220)
        let logoSize: CGFloat = ResponsiveSystem.value(extraSmall: 120, small: 140, standard: 160)
        
        return VStack(spacing: ResponsiveSystem.value(extraSmall: 10, small: 12, standard: 16)) {
            logoView(circleSize: circleSize, logoSize: logoSize)
            
            headerTextSection
        }
        .padding(.top, ResponsiveSystem.value(
            extraSmall: 6,
            small: 8,
            standard: 12
        ))
        .padding(.bottom, ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10))
        .frame(maxWidth: .infinity)
    }
    
    private func logoView(circleSize: CGFloat, logoSize: CGFloat) -> some View {
        ZStack {
            // Outer glow rings (matching splash screen)
            ForEach(0..<2) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0).opacity(max(0.0, 0.4 - Double(index) * 0.2)),
                                Color(red: 0.58, green: 0.0, blue: 1.0).opacity(max(0.0, 0.3 - Double(index) * 0.15))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: circleSize + CGFloat(index) * 20, height: circleSize + CGFloat(index) * 20)
                    .scaleEffect(1.0 + CGFloat(index) * 0.1)
                    .opacity(logoOpacity * (1.0 - Double(index) * 0.3))
            }
            
            // Dark container for white logo (matching splash screen) - BIGGER
            Circle()
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.5), radius: 50, x: 0, y: 25)
                .shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 15)
                .opacity(logoOpacity)
            
            // Logo (matching splash screen pattern) - SMALLER to fit inside circle
            Group {
                if let uiImage = LogoLoader.loadAgosecLogo() {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: logoSize, height: logoSize)
                } else {
                    Image(systemName: "sparkles")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: logoSize, height: logoSize)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.48, blue: 1.0),
                                    Color(red: 0.58, green: 0.0, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
            .offset(y: logoFloat)
        }
    }
    
    private var headerTextSection: some View {
        VStack(spacing: 8) {
            Text("How can I help?")
                .font(.system(
                    size: ResponsiveSystem.value(extraSmall: 20, small: 22, standard: 24),
                    weight: .bold,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                .multilineTextAlignment(.center)
            
            Text("Choose how to start your AI session")
                .font(.system(
                    size: ResponsiveSystem.value(extraSmall: 14, small: 15, standard: 16),
                    weight: .regular,
                    design: .default
                ))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                .multilineTextAlignment(.center)
        }
    }
    
    private func startAnimations() {
        // Logo entrance animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Logo float animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                logoFloat = -8
            }
        }
        
        // Content entrance animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
    
    private var choiceButtonsSection: some View {
        let iconSize: CGFloat = ResponsiveSystem.value(extraSmall: 18, small: 20, standard: 24)
        let iconContainerSize: CGFloat = ResponsiveSystem.value(extraSmall: 32, small: 36, standard: 40)
        
        return VStack(spacing: ResponsiveSystem.value(
            extraSmall: 10,
            small: 12,
            standard: 16
        )) {
            Button(action: { 
                checkPhotoAccessAndShowPicker() 
            }) {
                HStack(spacing: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 16)) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                        .frame(width: iconContainerSize, height: iconContainerSize)
                        .background(
                            Circle()
                                .fill(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Use Screenshots")
                            .font(.system(
                                size: ResponsiveSystem.value(extraSmall: 15, small: 16, standard: 17),
                                weight: .semibold,
                                design: .default
                            ))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        Text("Import screenshots for context")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    }
                    
                    Spacer()
                }
                .padding(ResponsiveSystem.value(
                    extraSmall: 12,
                    small: 14,
                    standard: 20
                ))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: {
                onChoiceMade(.continueWithoutContext)
            }) {
                HStack(spacing: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 16)) {
                    Image(systemName: "message.circle")
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(Color(red: 0.58, green: 0.0, blue: 1.0))
                        .frame(width: iconContainerSize, height: iconContainerSize)
                        .background(
                            Circle()
                                .fill(Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Continue without Context")
                            .font(.system(
                                size: ResponsiveSystem.value(extraSmall: 15, small: 16, standard: 17),
                                weight: .semibold,
                                design: .default
                            ))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        Text("Start fresh conversation")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    }
                    
                    Spacer()
                }
                .padding(ResponsiveSystem.value(
                    extraSmall: 12,
                    small: 14,
                    standard: 20
                ))
                .frame(maxWidth: .infinity)
                .background(
                    Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: ResponsiveSystem.value(
                        extraSmall: 14,
                        small: 16,
                        standard: 20
                    ))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ResponsiveSystem.value(
                        extraSmall: 14,
                        small: 16,
                        standard: 20
                    ))
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
                Text("Tips")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .top, spacing: 4) {
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("Screenshots are optional")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 4) {
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("Import 1-5 screenshots")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 4) {
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("Context helps AI")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.white.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.58, blue: 0.0).opacity(0.3),
                            Color(red: 1.0, green: 0.58, blue: 0.0).opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private var deleteConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("Delete Screenshots?")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                
                Text("Would you like to delete the screenshots from Photos after importing?")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    Button(action: handleUseAndDelete) {
                        Text("Use & Delete")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    Button(action: handleUseOnly) {
                        Text("Use Only")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                    }
                    
                    Button(action: handleDeleteCancel) {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 320)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
    }
    
    private var photoAccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("Photo Access Required")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                
                Text("Photo access is required to import screenshots. You can enable it in Settings or skip this step.")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    Button(action: handlePhotoAccessOpenSettings) {
                        Text("Open Settings")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .cornerRadius(10)
                    }
                    
                    Button(action: handlePhotoAccessSkip) {
                        Text("Skip")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 320)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
