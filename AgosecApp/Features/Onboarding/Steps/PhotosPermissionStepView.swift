import SwiftUI
import PhotosUI
import UIComponents

struct PhotosPermissionStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var photosStatus: PHAuthorizationStatus = .notDetermined
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: min(geometry.size.height * 0.03, 24)) {
                    Spacer(minLength: max(geometry.size.height * 0.1, 40))
                    
                    Image(systemName: "photo.fill")
                        .font(.system(size: min(geometry.size.width * 0.2, 80)))
                        .foregroundColor(.green)
                    
                    Text("Photo Access")
                        .font(.system(size: min(geometry.size.width * 0.06, 24), weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 16) {
                        Text("Allow access to screenshots for AI context")
                            .font(.system(size: min(geometry.size.width * 0.04, 16)))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Text("Screenshots are optional - you can skip this step")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer(minLength: max(geometry.size.height * 0.1, 40))
                    
                    VStack(spacing: 12) {
                        if photosStatus == .notDetermined {
                            ActionButton(title: "Allow Photo Access", action: requestPhotoAccess)
                        }
                        
                        if photosStatus == .authorized || photosStatus == .limited {
                            ActionButton(title: "Continue", action: onNext)
                        }
                        
                        if photosStatus == .denied || photosStatus == .restricted {
                            ActionButton(title: "Open Settings", action: openSettings)
                            ActionButton(title: "Skip for Now", action: onNext, style: .secondary)
                        }
                    }
                    .padding(.horizontal, max(geometry.size.width * 0.1, 24))
                    .padding(.bottom, 40)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear {
            checkPhotoStatus()
        }
    }
    
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                photosStatus = status
            }
        }
    }
    
    private func checkPhotoStatus() {
        photosStatus = PHPhotoLibrary.authorizationStatus()
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}