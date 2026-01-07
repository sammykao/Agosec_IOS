import SwiftUI
import PhotosUI

struct AgentIntroView: View {
    let onChoiceMade: (IntroChoice) -> Void
    
    @State private var showingPhotoPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showingDeleteConfirmation = false
    
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
            PhotoPicker(selectedImages: $selectedImages) {
                if !selectedImages.isEmpty {
                    showingDeleteConfirmation = true
                }
            }
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
            Button(action: { showingPhotoPicker = true }) {
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
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else { return }
            
            parent.selectedImages.removeAll()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.parent.selectedImages.append(image)
                            
                            if self?.parent.selectedImages.count == results.count {
                                self?.parent.onSelectionComplete()
                            }
                        }
                    }
                }
            }
        }
    }
}