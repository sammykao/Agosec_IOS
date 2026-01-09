import SwiftUI
import SharedCore
import UIComponents

@main
struct AgosecApp: App {
    @StateObject private var entitlementService = EntitlementService()
    @StateObject private var permissionsService = PermissionsService()
    @StateObject private var toastManager = ToastManager.shared
    
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(entitlementService)
                .environmentObject(permissionsService)
                .environmentObject(toastManager)
                .toastOverlay(toastManager: toastManager)
                .onOpenURL { url in
                    DeepLinkService.shared.handle(url: url)
                }
        }
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
}