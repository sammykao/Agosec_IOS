import Photos
import SharedCore
import SwiftUI
import UIKit

// Custom Photos-based picker to ensure we get PHAsset identifiers.
struct PhotoPicker: View {
    @Binding var selectedImages: [UIImage]
    let onLoadingStarted: () -> Void
    let onSelectionComplete: ([UIImage], [String]) -> Void
    let onError: ((Error) -> Void)?

    @StateObject private var model = PhotosAssetPickerModel()
    @Environment(\ .dismiss) private var dismiss

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

    var body: some View {
        VStack(spacing: 0) {
            header

            if model.isLoading {
                ProgressView("Loading photos...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.02))
            } else {
                GeometryReader { proxy in
                    let layout = GridLayout(
                        width: proxy.size.width,
                        columns: 3,
                        spacing: 8,
                        horizontalPadding: 12
                    )
                    ScrollView {
                        LazyVGrid(columns: layout.columns, spacing: layout.spacing) {
                            ForEach(model.assets, id: \ .localIdentifier) { asset in
                                PhotoGridCell(
                                    thumbnail: model.thumbnails[asset.localIdentifier],
                                    isSelected: model.selectedIds.contains(asset.localIdentifier),
                                    cellSize: layout.cellSize,
                                    onTap: { model.toggleSelection(asset) }
                                )
                                .onAppear {
                                    model.requestThumbnailIfNeeded(for: asset, targetSize: layout.thumbnailSize)
                                }
                            }
                        }
                        .padding(.horizontal, layout.horizontalPadding)
                        .padding(.vertical, layout.spacing)
                    }
                }
            }

            footer
        }
        .onAppear {
            model.loadAssets()
        }
    }

    private var header: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.red)

            Spacer()

            Text("Select Screenshots")
                .font(.system(size: 16, weight: .semibold))

            Spacer()

            Button("Use") {
                confirmSelection()
            }
            .disabled(model.selectedIds.isEmpty)
            .foregroundColor(model.selectedIds.isEmpty ? .gray : .blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(white: 0.98))
    }

    private var footer: some View {
        HStack {
            Text("Selected: \(model.selectedIds.count)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            Spacer()

            Button("Use Selected") {
                confirmSelection()
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.selectedIds.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(white: 0.98))
    }

    private func confirmSelection() {
        guard !model.selectedIds.isEmpty else { return }
        onLoadingStarted()
        let selectedAssets = model.assets.filter { model.selectedIds.contains($0.localIdentifier) }
        FileLogger.shared.log("Photos picker confirm: assets=\(selectedAssets.count)", level: .info)

        model.loadFullImages(for: selectedAssets) { images in
            DispatchQueue.main.async {
                selectedImages = images
                let identifiers = selectedAssets.map { $0.localIdentifier }
                FileLogger.shared.log(
                    "Photos picker complete: images=\(images.count) assets=\(identifiers.count)",
                    level: .info
                )
                onSelectionComplete(images, identifiers)
                dismiss()
            }
        } onError: { error in
            DispatchQueue.main.async {
                FileLogger.shared.log("Photos picker error: \(error)", level: .error)
                onError?(error)
                dismiss()
            }
        }
    }
}

private final class PhotosAssetPickerModel: ObservableObject {
    @Published var assets: [PHAsset] = []
    @Published var thumbnails: [String: UIImage] = [:]
    @Published var selectedIds: Set<String> = []
    @Published var isLoading = true

    private let imageManager = PHCachingImageManager()

    func loadAssets() {
        isLoading = true
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        FileLogger.shared.log("Photos picker auth status: \(status.rawValue)", level: .debug)

        guard status == .authorized || status == .limited else {
            isLoading = false
            return
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 200
        let results = PHAsset.fetchAssets(with: .image, options: options)

        var fetched: [PHAsset] = []
        results.enumerateObjects { asset, _, _ in
            fetched.append(asset)
        }

        assets = fetched
        isLoading = false
        FileLogger.shared.log("Photos picker loaded assets: \(assets.count)", level: .info)
    }

    func toggleSelection(_ asset: PHAsset) {
        let id = asset.localIdentifier
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }

    func requestThumbnailIfNeeded(for asset: PHAsset, targetSize: CGSize) {
        let id = asset.localIdentifier
        guard thumbnails[id] == nil else { return }

        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast

        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            guard let self = self, let image = image else { return }
            self.thumbnails[id] = image
        }
    }

    func loadFullImages(for assets: [PHAsset], completion: @escaping ([UIImage]) -> Void, onError: @escaping (Error) -> Void) {
        guard !assets.isEmpty else {
            completion([])
            return
        }

        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact

        let targetSize = CGSize(width: 2048, height: 2048)
        let group = DispatchGroup()
        var images: [UIImage] = []
        var errors: [Error] = []

        for asset in assets {
            group.enter()
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                if let image = image {
                    images.append(image)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    errors.append(error)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if !errors.isEmpty {
                onError(errors[0])
            } else {
                completion(images)
            }
        }
    }
}

private struct PhotoGridCell: View {
    let thumbnail: UIImage?
    let isSelected: Bool
    let cellSize: CGFloat
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cellSize, height: cellSize)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.black.opacity(0.05))
                    .frame(width: cellSize, height: cellSize)
            }

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .padding(6)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

private struct GridLayout {
    let columns: [GridItem]
    let cellSize: CGFloat
    let thumbnailSize: CGSize
    let spacing: CGFloat
    let horizontalPadding: CGFloat

    init(width: CGFloat, columns: Int, spacing: CGFloat, horizontalPadding: CGFloat) {
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        let availableWidth = max(0, width - horizontalPadding * 2 - spacing * CGFloat(columns - 1))
        self.cellSize = floor(availableWidth / CGFloat(columns))
        self.thumbnailSize = CGSize(
            width: cellSize * UIScreen.main.scale,
            height: cellSize * UIScreen.main.scale
        )
        self.columns = Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: columns)
    }
}
