import SwiftUI
import PhotosUI
import SharedCore
import UIComponents

struct AgentIntroView: View {
    let onChoiceMade: (IntroChoice) -> Void
    
    @State private var showingPhotoPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showingDeleteConfirmation = false
    @State private var photoAccessStatus: PHAuthorizationStatus = .notDetermined
    @State private var showingPhotoAccessError = false
    @State private var photoLoadErrors: [Error] = []
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            headerSection
            
            choiceButtonsSection
            
            Spacer()
            
            tipsSection
        }
        .padding()
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker(
                selectedImages: $selectedImages,
                onSelectionComplete: {
                    if !selectedImages.isEmpty {
                        showingDeleteConfirmation = true
                    }
                },
                onError: { error in
                    let message = ErrorMapper.userFriendlyMessage(from: error)
                    toastManager.show(message, type: .error, duration: 4.0)
                }
            )
        }
        .alert("Delete Screenshots?", isPresented: $showingDeleteConfirmation) {
            Button("Use & Delete", role: .destructive) {
                onChoiceMade(.useAndDeleteScreenshots(selectedImages))
            }
            Button("Use Only", role: .cancel) {
                onChoiceMade(.useScreenshots(selectedImages))
            }
            Button("Cancel", role: .cancel) { }
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
            showingPhotoPicker = true
        case .denied, .restricted:
            showingPhotoAccessError = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    photoAccessStatus = newStatus
                    if newStatus == .authorized || newStatus == .limited {
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
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("How can I help?")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Choose how to start your AI session")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    private var choiceButtonsSection: some View {
        VStack(spacing: 16) {
            Button(action: { checkPhotoAccessAndShowPicker() }) {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 32))
                    
                    VStack(spacing: 4) {
                        Text("Use Screenshots")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Import screenshots for context")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                )
            }
            .foregroundColor(.primary)
            
            Button(action: { onChoiceMade(.continueWithoutContext) }) {
                VStack(spacing: 12) {
                    Image(systemName: "message.circle")
                        .font(.system(size: 32))
                    
                    VStack(spacing: 4) {
                        Text("Continue without Context")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Start fresh conversation")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
            }
            .foregroundColor(.primary)
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 Tips")
                .font(.system(size: 16, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Screenshots are optional - skip if you prefer")
                    .font(.system(size: 14))
                Text("• You can import 1-5 screenshots at once")
                    .font(.system(size: 14))
                Text("• Context helps AI understand your situation")
                    .font(.system(size: 14))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let onSelectionComplete: () -> Void
    let onError: ((Error) -> Void)?
    
    init(selectedImages: Binding<[UIImage]>, onSelectionComplete: @escaping () -> Void, onError: ((Error) -> Void)? = nil) {
        self._selectedImages = selectedImages
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
        private var errors: [Error] = []
        private var expectedCount: Int = 0
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else { return }
            
            parent.selectedImages.removeAll()
            loadedImages.removeAll()
            errors.removeAll()
            expectedCount = results.count
            
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        self?.errors.append(error)
                    } else if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.loadedImages.append(image)
                        }
                    }
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                
                // If we have some images, use them (partial success)
                if !self.loadedImages.isEmpty {
                    self.parent.selectedImages = self.loadedImages
                    
                    // Show warning if some images failed
                    if !self.errors.isEmpty {
                        let error = NSError(domain: "PhotoPicker", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "Some images failed to load. \(self.loadedImages.count) of \(self.expectedCount) loaded successfully."
                        ])
                        self.parent.onError?(error)
                    }
                    
                    self.parent.onSelectionComplete()
                } else if !self.errors.isEmpty {
                    // All images failed
                    self.parent.onError?(self.errors.first ?? NSError(domain: "PhotoPicker", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to load images"
                    ]))
                }
            }
        }
    }
}