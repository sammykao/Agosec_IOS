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

    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                VStack(spacing: 10) {
                    VStack(spacing: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 12)) {
                        AgentIntroHeaderSection()

                        AgentIntroChoiceButtonsSection(
                            onUseScreenshots: { checkPhotoAccessAndShowPicker() },
                            onContinue: { onChoiceMade(.continueWithoutContext) }
                        )
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    }
                    .padding(.vertical, ResponsiveSystem.value(extraSmall: 12, small: 14, standard: 16))
                    .padding(.horizontal, ResponsiveSystem.value(extraSmall: 16, small: 20, standard: 24))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.07, green: 0.2, blue: 0.45).opacity(0.18),
                                        Color(red: 0.25, green: 0.12, blue: 0.4).opacity(0.16),
                                        Color(red: 0.06, green: 0.24, blue: 0.35).opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.12, green: 0.32, blue: 0.6).opacity(0.45), lineWidth: 1)
                            )
                            .overlay(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.18, green: 0.36, blue: 0.6).opacity(0.18),
                                        Color.clear
                                    ],
                                    center: .topLeading,
                                    startRadius: 10,
                                    endRadius: 180
                                )
                            )
                    )
                    .frame(maxWidth: min(proxy.size.width * 0.86, 360))

                    AgentIntroChevronIndicator()
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                }
                .frame(maxWidth: .infinity)
                .position(x: proxy.size.width / 2, y: proxy.size.height * 0.35)
            }

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
        // Content entrance animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }

    }
}

private struct AgentIntroChevronIndicator: View {
    @State private var pulse = false

    var body: some View {
        Text(">>>>")
            .font(.system(size: 24, weight: .semibold, design: .monospaced))
            .foregroundColor(Color(red: 0.12, green: 0.32, blue: 0.6).opacity(0.7))
            .scaleEffect(pulse ? 1.08 : 1.0)
            .opacity(pulse ? 1.0 : 0.6)
            .padding(.top, 6)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
