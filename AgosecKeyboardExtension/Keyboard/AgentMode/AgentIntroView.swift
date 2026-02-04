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
    @State private var contentScale: CGFloat = 0.98
    @State private var ambientShift: CGFloat = 0.0

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack {
                    introBackground(in: proxy)

                    VStack(spacing: 10) {
                        VStack(spacing: ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 12)) {
                            AgentIntroHeaderSection()

                            AgentIntroChoiceButtonsSection(
                                onUseScreenshots: { checkPhotoAccessAndShowPicker() },
                                onContinue: { onChoiceMade(.continueWithoutContext) }
                            )
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)
                            .scaleEffect(contentScale)
                        }
                        .padding(.vertical, ResponsiveSystem.value(extraSmall: 12, small: 14, standard: 16))
                        .padding(.horizontal, ResponsiveSystem.value(extraSmall: 16, small: 20, standard: 24))
                        .frame(
                            maxWidth: min(proxy.size.width * 0.9, 380),
                            minHeight: ResponsiveSystem.value(extraSmall: 150, small: 170, standard: 190)
                        )

                    }
                    .frame(maxWidth: .infinity)
                .position(x: proxy.size.width / 2, y: proxy.size.height * 0.38)
            }
                .blur(radius: (showingDeleteConfirmation || showingPhotoAccessError) ? 8 : 0)
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
        .onChange(of: selectedImages) { images in
            guard !images.isEmpty else { return }
            if !showingDeleteConfirmation {
                FileLogger.shared.log("Selected images changed -> show delete confirmation", level: .debug)
                showingDeleteConfirmation = true
            }
        }
        .onChange(of: showingDeleteConfirmation) { value in
            FileLogger.shared.log("showingDeleteConfirmation changed -> \(value)", level: .debug)
        }
        .loadingOverlay(isPresented: isLoadingImages, message: loadingMessage)
        .fullScreenCover(
            isPresented: $showingPhotoPicker,
            onDismiss: {
                FileLogger.shared.log("Photo picker dismissed", level: .debug)
                // Delay notification to ensure keyboard view is stable
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
                        FileLogger.shared.log(
                            "Photo picker selection complete. images=\(images.count) assets=\(assetIdentifiers.count)",
                            level: .info
                        )
                        // Delay to ensure sheet is fully dismissed and keyboard is stable
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isLoadingImages = false
                            selectedImages = images
                            selectedAssetIdentifiers = assetIdentifiers
                            FileLogger.shared.log(
                                "AgentIntroView updated selectedImages=\(selectedImages.count) assets=\(selectedAssetIdentifiers.count)",
                                level: .debug
                            )

                            if !images.isEmpty {
                                // Additional delay to ensure view is ready for alert presentation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    FileLogger.shared.log("Showing delete confirmation overlay", level: .debug)
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
                        FileLogger.shared.log("Photo picker error: \(error)", level: .error)
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

    private func introBackground(in proxy: GeometryProxy) -> some View {
        let inset = ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10)
        return RoundedRectangle(cornerRadius: 22)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.08),
                        Color(red: 0.08, green: 0.08, blue: 0.12),
                        Color(red: 0.06, green: 0.06, blue: 0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [
                        AgentIntroTheme.accentBlue.opacity(0.16),
                        AgentIntroTheme.accentPurple.opacity(0.12),
                        Color.clear
                    ]),
                    center: UnitPoint(x: 0.5 + ambientShift, y: 0.5 - ambientShift),
                    startRadius: 80,
                    endRadius: 320
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 18, x: 0, y: 10)
            .frame(
                width: max(0, proxy.size.width - CGFloat(inset * 2)),
                height: max(0, proxy.size.height - CGFloat(inset * 2))
            )
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
    }

    private func checkPhotoAccessStatus() {
        photoAccessStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        FileLogger.shared.log("Photo access status: \(photoAccessStatus.rawValue)", level: .debug)
    }

    private func checkPhotoAccessAndShowPicker() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        FileLogger.shared.log("Check photo access: \(status.rawValue)", level: .debug)

        switch status {
        case .authorized, .limited:
            // Notify that photo selection is starting
            NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionStarted"), object: nil)
            showingPhotoPicker = true
        case .denied, .restricted:
            FileLogger.shared.log("Photo access denied/restricted", level: .warning)
            showingPhotoAccessError = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    photoAccessStatus = newStatus
                    if newStatus == .authorized || newStatus == .limited {
                        FileLogger.shared.log("Photo access granted after request", level: .info)
                        // Notify that photo selection is starting
                        NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionStarted"), object: nil)
                        showingPhotoPicker = true
                    } else {
                        FileLogger.shared.log("Photo access denied after request", level: .warning)
                        showingPhotoAccessError = true
                    }
                }
            }
        @unknown default:
            FileLogger.shared.log("Photo access unknown status", level: .warning)
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

        FileLogger.shared.log(
            "Confirm use+delete. images=\(imagesCopy.count) assets=\(identifiersCopy.count)",
            level: .info
        )
        // Delay to ensure keyboard is stable before processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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

        FileLogger.shared.log("Confirm use only. images=\(imagesCopy.count)", level: .info)
        // Delay to ensure keyboard is stable before processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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

        FileLogger.shared.log("Delete confirmation cancelled", level: .debug)
        // Delay notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
                contentScale = 1.0
            }
        }

        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            ambientShift = 0.44
        }

    }
}

private extension View {
    @ViewBuilder
    func presentationBackgroundIfAvailable(_ color: Color) -> some View {
        if #available(iOS 16.4, *) {
            self.presentationBackground(color)
        } else {
            self
        }
    }
}
