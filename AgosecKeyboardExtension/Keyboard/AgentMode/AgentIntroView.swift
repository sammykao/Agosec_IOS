import SwiftUI
import Photos
import SharedCore
import UIComponents
import UIKit

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
                    AgentIntroHeaderSection(
                        logoScale: logoScale,
                        logoOpacity: logoOpacity,
                        logoFloat: logoFloat
                    )
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(y: logoFloat)

                    AgentIntroChoiceButtonsSection(
                        onUseScreenshots: { checkPhotoAccessAndShowPicker() },
                        onContinue: { onChoiceMade(.continueWithoutContext) }
                    )
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                    AgentIntroTipsSection()
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
                AgentIntroDeleteConfirmationOverlay(
                    onUseAndDelete: handleUseAndDelete,
                    onUseOnly: handleUseOnly,
                    onCancel: handleDeleteCancel
                )
            }

            if showingPhotoAccessError {
                AgentIntroPhotoAccessOverlay(
                    onOpenSettings: handlePhotoAccessOpenSettings,
                    onSkip: handlePhotoAccessSkip
                )
            }
        }
        .onAppear {
            startAnimations()
            checkPhotoAccessStatus()
        }
        .loadingOverlay(isPresented: isLoadingImages, message: loadingMessage)
        .sheet(
            isPresented: $showingPhotoPicker,
            onDismiss: {
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
            },
            content: {
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
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("PhotoSelectionEnded"),
                                    object: nil
                                )
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
                        NotificationCenter.default.post(
                            name: NSNotification.Name("PhotoSelectionEnded"),
                            object: nil
                        )
                        let message = ErrorMapper.userFriendlyMessage(from: error)
                        toastManager.show(message, type: .error, duration: 4.0)
                    }
                )
            }
        )
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
}
