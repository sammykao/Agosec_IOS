import SwiftUI
import PhotosUI

struct PhotosPermissionStepView: View {
    @EnvironmentObject var permissionsService: PermissionsService
    @State private var photosStatus: PHAuthorizationStatus = .notDetermined
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "photo.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Photo Access")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                Text("Allow access to screenshots for AI context")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("Screenshots are optional - you can skip this step")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
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
            .padding(.horizontal)
        }
        .padding()
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