import SwiftUI
import SharedCore

@main
struct AgosecApp: App {
    @StateObject private var entitlementService = EntitlementService()
    @StateObject private var permissionsService = PermissionsService()
    
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(entitlementService)
                .environmentObject(permissionsService)
                .onOpenURL { url in
                    DeepLinkService.shared.handle(url: url)
                }
        }
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
}