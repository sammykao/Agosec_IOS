import SwiftUI
import SharedCore
import UIComponents

@main
struct AgosecApp: App {
    @StateObject private var entitlementService = EntitlementService()
    @StateObject private var permissionsService = PermissionsService()
    @StateObject private var toastManager = ToastManager.shared
    @State private var showSplash = true
    
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Background gradient for entire app
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.98, blue: 1.0),
                        Color(red: 0.95, green: 0.96, blue: 0.98),
                        Color(red: 0.97, green: 0.97, blue: 0.99)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if showSplash {
                    SplashScreenView(logoName: "agosec_logo", appName: "Agosec")
                        .transition(.opacity)
                        .onAppear {
                            // Show splash screen for minimum 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    showSplash = false
                                }
                            }
                        }
                } else {
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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)
            .animation(.easeInOut(duration: 0.4), value: showSplash)
        }
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
}