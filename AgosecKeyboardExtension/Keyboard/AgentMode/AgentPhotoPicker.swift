import Foundation
import PhotosUI
import SharedCore
import SwiftUI
import UIKit

// Extracted from AgentIntroView to keep the view focused on UI flow.
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

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Handle empty selection
            guard !results.isEmpty else {
                picker.dismiss(animated: true)
                return
            }

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

            for result in results {
                // Capture asset identifier if available (for deletion)
                if let assetIdentifier = result.assetIdentifier {
                    self.assetIdentifiers.append(assetIdentifier)
                }

                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        guard let self = self else {
                            group.leave()
                            return
                        }

                        defer {
                            group.leave()
                        }

                        if let error = error {
                            self.errors.append(error)
                            return
                        }

                        if let image = image as? UIImage {
                            // Resize image to reduce memory usage (max 2048px on longest side)
                            let resizedImage = Coordinator.resizeImageIfNeeded(image, maxDimension: 2048)
                            self.loadedImages.append(resizedImage)
                            return
                        }

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
                    picker.dismiss(animated: true)
                    return
                }

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
                            // Call completion handler - if this crashes, the exception handler will catch it
                            self.parent.onSelectionComplete(self.loadedImages, self.assetIdentifiers)
                        } else if !self.errors.isEmpty {
                            // Complete failure - all images failed
                            let firstError = self.errors.first ?? NSError(
                                domain: "PhotoPicker",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to load images"]
                            )
                            self.parent.onError?(firstError)
                        } else {
                            // Edge case: no images and no errors (shouldn't happen)
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

        static func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
            let size = image.size
            let maxSize = max(size.width, size.height)

            // Only resize if image is larger than max dimension
            guard maxSize > maxDimension else {
                return image
            }

            let scale = maxDimension / maxSize
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            defer { UIGraphicsEndImageContext() }

            image.draw(in: CGRect(origin: .zero, size: newSize))
            return UIGraphicsGetImageFromCurrentImageContext() ?? image
        }
    }
}
