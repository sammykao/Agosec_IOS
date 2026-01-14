import SwiftUI
import SharedCore
import UIComponents

@main
struct AgosecApp: App {
    @StateObject private var entitlementService = EntitlementService()
    @StateObject private var permissionsService = PermissionsService()
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var appInitializer = AppInitializer()
    
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appInitializer.isInitialized {
                    ContentView()
                        .environmentObject(entitlementService)
                        .environmentObject(permissionsService)
                        .environmentObject(toastManager)
                        .toastOverlay(toastManager: toastManager)
                        .onOpenURL { url in
                            DeepLinkService.shared.handle(url: url)
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                } else {
                    SplashScreenView(logoName: "agosec_logo", appName: "Agosec")
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: appInitializer.isInitialized)
        }
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
}