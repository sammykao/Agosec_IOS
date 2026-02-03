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

        deinit {
            FileLogger.shared.log("PHPicker coordinator deinit", level: .warning)
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            FileLogger.shared.log("PHPicker didFinishPicking. results=\(results.count)", level: .debug)
            guard !results.isEmpty else {
                FileLogger.shared.log("PHPicker results empty (user cancelled)", level: .info)
                picker.dismiss(animated: true)
                return
            }

            FileLogger.shared.log("PHPicker starting load for \(results.count) items", level: .debug)
            parent.onLoadingStarted()

            resetState(with: results)
            let group = DispatchGroup()
            loadImages(from: results, group: group)
            notifyCompletion(group: group, picker: picker)
        }

        private func resetState(with results: [PHPickerResult]) {
            parent.selectedImages.removeAll()
            loadedImages.removeAll()
            assetIdentifiers.removeAll()
            errors.removeAll()
            expectedCount = results.count
            FileLogger.shared.log("PHPicker reset state. expectedCount=\(expectedCount)", level: .debug)
        }

        private func loadImages(from results: [PHPickerResult], group: DispatchGroup) {
            for result in results {
                captureAssetIdentifier(from: result)
                group.enter()
                loadImage(result, group: group)
            }
        }

        private func captureAssetIdentifier(from result: PHPickerResult) {
            if let assetIdentifier = result.assetIdentifier {
                assetIdentifiers.append(assetIdentifier)
                FileLogger.shared.log("PHPicker captured asset id", level: .debug)
            }
        }

        private func loadImage(_ result: PHPickerResult, group: DispatchGroup) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self else {
                        group.leave()
                        return
                    }

                    defer { group.leave() }

                    if let error = error {
                        FileLogger.shared.log("PHPicker load error: \(error)", level: .error)
                        self.errors.append(error)
                        return
                    }

                    if let image = image as? UIImage {
                        let resizedImage = Coordinator.resizeImageIfNeeded(image, maxDimension: 2048)
                        self.loadedImages.append(resizedImage)
                        FileLogger.shared.log("PHPicker loaded image (\(self.loadedImages.count)/\(self.expectedCount))", level: .debug)
                        return
                    }

                    FileLogger.shared.log("PHPicker invalid image object", level: .error)
                    self.errors.append(self.invalidImageError())
                }
            }
        }

        private func invalidImageError() -> NSError {
            NSError(
                domain: "PhotoPicker",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid image format"]
            )
        }

        private func notifyCompletion(group: DispatchGroup, picker: PHPickerViewController) {
            FileLogger.shared.log("PHPicker notify: waiting for loads to finish", level: .debug)
            group.notify(queue: .main) { [weak self] in
                guard let self = self else {
                    picker.dismiss(animated: true)
                    return
                }

                FileLogger.shared.log("PHPicker notify: loads finished, dismissing", level: .debug)
                self.dismissPicker(picker)
            }
        }

        private func dismissPicker(_ picker: PHPickerViewController) {
            FileLogger.shared.log("PHPicker dismissing picker", level: .debug)
            picker.dismiss(animated: true) { [weak self] in
                FileLogger.shared.log("PHPicker dismiss completion", level: .debug)
                guard let self = self else {
                    FileLogger.shared.log("PHPicker finalize skipped: coordinator released", level: .warning)
                    return
                }
                FileLogger.shared.log("PHPicker finalize starting", level: .debug)
                self.finalizeSelection()
            }
        }

        private func finalizeSelection() {
            if !loadedImages.isEmpty {
                FileLogger.shared.log("PHPicker finalize: loaded images", level: .debug)
                handleLoadedImages()
            } else if !errors.isEmpty {
                FileLogger.shared.log("PHPicker finalize: errors present", level: .warning)
                handleLoadingFailure()
            } else {
                FileLogger.shared.log("PHPicker finalize: unexpected empty state", level: .error)
                handleUnexpectedState()
            }
        }

        private func handleLoadedImages() {
            if !errors.isEmpty {
                parent.onError?(partialLoadError())
            }
            parent.selectedImages = loadedImages
            FileLogger.shared.log(
                "PHPicker handleLoadedImages -> onSelectionComplete images=\(loadedImages.count) assets=\(assetIdentifiers.count)",
                level: .info
            )
            parent.onSelectionComplete(loadedImages, assetIdentifiers)
        }

        private func partialLoadError() -> NSError {
            let errorMessage = "\(errors.count) of \(expectedCount) image(s) failed to load"
            let successMessage = "\(loadedImages.count) of \(expectedCount) image(s) loaded successfully."
            return NSError(
                domain: "PhotoPicker",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "\(successMessage) \(errorMessage)"]
            )
        }

        private func handleLoadingFailure() {
            let firstError = errors.first ?? NSError(
                domain: "PhotoPicker",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to load images"]
            )
            parent.onError?(firstError)
        }

        private func handleUnexpectedState() {
            let unknownError = NSError(
                domain: "PhotoPicker",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Unexpected error: No images were loaded"]
            )
            parent.onError?(unknownError)
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
