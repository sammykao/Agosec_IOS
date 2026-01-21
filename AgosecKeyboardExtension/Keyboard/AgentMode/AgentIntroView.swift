import SwiftUI
import PhotosUI
import SharedCore
import UIComponents

struct AgentIntroView: View {
    let onChoiceMade: (IntroChoice) -> Void
    let onClose: () -> Void
    
    @State private var showingPhotoPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var selectedAssetIdentifiers: [String] = []
    @State private var showingDeleteConfirmation = false
    @State private var photoAccessStatus: PHAuthorizationStatus = .notDetermined
    @State private var showingPhotoAccessError = false
    @State private var photoLoadErrors: [Error] = []
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
            ScrollView {
                VStack(spacing: 32) {
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
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
            }
            .background(Color.clear)
            
            // Loading overlay when images are being loaded
            if isLoadingImages {
                LoadingOverlay(message: loadingMessage)
            }
        }
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showingPhotoPicker, onDismiss: {
            // Reset loading state when sheet is dismissed
            // This handles the case where user cancels the picker
            if isLoadingImages {
                isLoadingImages = false
                print("📸 PhotoPicker: Sheet dismissed - resetting loading state")
            }
            // Notify that photo selection has ended
            NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
        }) {
            PhotoPicker(
                selectedImages: $selectedImages,
                onLoadingStarted: {
                    isLoadingImages = true
                    loadingMessage = "Loading images..."
                },
                onSelectionComplete: { images, assetIdentifiers in
                    // Delay to ensure sheet is fully dismissed before showing alert
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isLoadingImages = false
                        selectedImages = images
                        selectedAssetIdentifiers = assetIdentifiers
                        if !images.isEmpty {
                            // Small delay to ensure view is ready for alert presentation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                    print("❌ PhotoPicker Error: \(error.localizedDescription)")
                    toastManager.show(message, type: .error, duration: 4.0)
                }
            )
        }
        .alert("Delete Screenshots?", isPresented: $showingDeleteConfirmation) {
            Button("Use & Delete", role: .destructive) {
                // Notify that photo selection has ended before making choice
                NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
                onChoiceMade(.useAndDeleteScreenshots(selectedImages, selectedAssetIdentifiers))
            }
            Button("Use Only", role: .cancel) {
                // Notify that photo selection has ended before making choice
                NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
                onChoiceMade(.useScreenshots(selectedImages))
            }
            Button("Cancel", role: .cancel) {
                // Notify that photo selection has ended
                NotificationCenter.default.post(name: NSNotification.Name("PhotoSelectionEnded"), object: nil)
            }
        } message: {
            Text("Would you like to delete the screenshots from Photos after importing?")
        }
        .alert("Photo Access Required", isPresented: $showingPhotoAccessError) {
            Button("Open Settings") {
                openSettings()
            }
            Button("Skip", role: .cancel) {
                onChoiceMade(.continueWithoutContext)
            }
        } message: {
            Text("Photo access is required to import screenshots. You can enable it in Settings or skip this step.")
        }
        .onAppear {
            checkPhotoAccessStatus()
        }
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
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Agosec Logo with animated glow (matching splash screen pattern)
            ZStack {
                // Outer glow rings (matching splash screen)
                ForEach(0..<2) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.4 - Double(index) * 0.2),
                                    Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.3 - Double(index) * 0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 180 + CGFloat(index) * 20, height: 180 + CGFloat(index) * 20)
                        .scaleEffect(1.0 + CGFloat(index) * 0.1)
                        .opacity(logoOpacity * (1.0 - Double(index) * 0.3))
                }
                
                // Dark container for white logo (matching splash screen)
                Circle()
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                    .frame(width: 180, height: 180)
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
                
                // Logo (matching splash screen pattern)
                Group {
                    if let uiImage = UIImage(named: "agosec_logo") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "sparkles")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
                .frame(width: 180, height: 180)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .offset(y: logoFloat)
            }
            
            Text("How can I help?")
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                .multilineTextAlignment(.center)
            
            Text("Choose how to start your AI session")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
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
        VStack(spacing: 16) {
            Button(action: { checkPhotoAccessAndShowPicker() }) {
                HStack(spacing: 16) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Use Screenshots")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        Text("Import screenshots for context")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    }
                    
                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: {
                print("🔄 Continue without Context button tapped")
                onChoiceMade(.continueWithoutContext)
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "message.circle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(red: 0.58, green: 0.0, blue: 1.0))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Continue without Context")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        Text("Start fresh conversation")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    }
                    
                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
                Text("Tips")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("Screenshots are optional - skip if you prefer")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                }
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("You can import 1-5 screenshots at once")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                }
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                    Text("Context helps AI understand your situation")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.white.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let onLoadingStarted: () -> Void
    let onSelectionComplete: ([UIImage], [String]) -> Void
    let onError: ((Error) -> Void)?
    
    init(
        selectedImages: Binding<[UIImage]>,
        onLoadingStarted: @escaping () -> Void,
        onSelectionComplete: @escaping ([UIImage], [String]) -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        self._selectedImages = selectedImages
        self.onLoadingStarted = onLoadingStarted
        self.onSelectionComplete = onSelectionComplete
        self.onError = onError
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = Config.shared.featureFlags.maxScreenshotsPerImport
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        private var loadedImages: [UIImage] = []
        private var assetIdentifiers: [String] = []
        private var errors: [Error] = []
        private var expectedCount: Int = 0
        private var pickerViewController: PHPickerViewController?
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Store reference to picker for delayed dismissal
            pickerViewController = picker
            
            // Handle empty selection
            guard !results.isEmpty else {
                print("📸 PhotoPicker: User cancelled or no selection")
                picker.dismiss(animated: true)
                return
            }
            
            print("📸 PhotoPicker: User selected \(results.count) image(s)")
            
            // Notify that loading has started
            parent.onLoadingStarted()
            
            // Clear previous state
            parent.selectedImages.removeAll()
            loadedImages.removeAll()
            assetIdentifiers.removeAll()
            errors.removeAll()
            expectedCount = results.count
            
            // Start loading images asynchronously
            let group = DispatchGroup()
            
            for (index, result) in results.enumerated() {
                // Capture asset identifier if available (for deletion)
                if let assetIdentifier = result.assetIdentifier {
                    self.assetIdentifiers.append(assetIdentifier)
                    print("📸 PhotoPicker: Image \(index + 1) - Asset ID: \(assetIdentifier)")
                } else {
                    print("⚠️ PhotoPicker: Image \(index + 1) - No asset identifier available")
                }
                
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    defer { group.leave() }
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("❌ PhotoPicker: Failed to load image \(index + 1): \(error.localizedDescription)")
                        self.errors.append(error)
                    } else if let image = image as? UIImage {
                        print("✅ PhotoPicker: Successfully loaded image \(index + 1) - Size: \(image.size)")
                        DispatchQueue.main.async {
                            self.loadedImages.append(image)
                        }
                    } else {
                        print("⚠️ PhotoPicker: Image \(index + 1) - Invalid image type")
                        let invalidError = NSError(
                            domain: "PhotoPicker",
                            code: -2,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid image format"]
                        )
                        self.errors.append(invalidError)
                    }
                }
            }
            
            // Wait for all images to load, then dismiss picker and notify
            group.notify(queue: .main) { [weak self] in
                guard let self = self else {
                    print("⚠️ PhotoPicker: Coordinator deallocated during image loading")
                    picker.dismiss(animated: true)
                    return
                }
                
                print("📸 PhotoPicker: Finished loading - \(self.loadedImages.count) successful, \(self.errors.count) failed")
                
                // Dismiss picker AFTER images are loaded
                picker.dismiss(animated: true) {
                    // Small delay after dismissal to ensure view hierarchy is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Handle results
                        if !self.loadedImages.isEmpty {
                            // Success - at least some images loaded
                            if !self.errors.isEmpty {
                                // Partial success - some images failed
                                let errorMessage = "\(self.errors.count) of \(self.expectedCount) image(s) failed to load"
                                print("⚠️ PhotoPicker: \(errorMessage)")
                                
                                let partialError = NSError(
                                    domain: "PhotoPicker",
                                    code: -1,
                                    userInfo: [
                                        NSLocalizedDescriptionKey: "\(self.loadedImages.count) of \(self.expectedCount) image(s) loaded successfully. \(errorMessage)"
                                    ]
                                )
                                self.parent.onError?(partialError)
                            }
                            
                            // Call completion with loaded images
                            print("✅ PhotoPicker: Calling onSelectionComplete with \(self.loadedImages.count) image(s)")
                            self.parent.onSelectionComplete(self.loadedImages, self.assetIdentifiers)
                        } else if !self.errors.isEmpty {
                            // Complete failure - all images failed
                            print("❌ PhotoPicker: All images failed to load")
                            let firstError = self.errors.first ?? NSError(
                                domain: "PhotoPicker",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to load images"]
                            )
                            self.parent.onError?(firstError)
                        } else {
                            // Edge case: no images and no errors (shouldn't happen)
                            print("⚠️ PhotoPicker: No images loaded and no errors reported")
                            let unknownError = NSError(
                                domain: "PhotoPicker",
                                code: -3,
                                userInfo: [NSLocalizedDescriptionKey: "Unexpected error: No images were loaded"]
                            )
                            self.parent.onError?(unknownError)
                        }
                    }
                }
            }
        }
    }
}