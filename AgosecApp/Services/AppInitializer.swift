import Foundation
import Combine
import SharedCore

/// Manages app initialization and loading state
class AppInitializer: ObservableObject {
    @Published var isInitialized: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        initializeApp()
    }
    
    private func initializeApp() {
        // Simulate initialization tasks
        // In a real app, this would include:
        // - Loading user preferences
        // - Checking authentication state
        // - Preloading critical data
        // - Setting up services
        
        Task {
            // Add a minimum display time for the splash screen (for better UX)
            let minimumDisplayTime: TimeInterval = 1.5
            
            let startTime = Date()
            
            // Perform initialization tasks
            await performInitialization()
            
            // Ensure splash screen is shown for at least minimumDisplayTime
            let elapsed = Date().timeIntervalSince(startTime)
            let remainingTime = max(0, minimumDisplayTime - elapsed)
            
            if remainingTime > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            await MainActor.run {
                isInitialized = true
            }
        }
    }
    
    private func performInitialization() async {
        // Simulate async initialization tasks
        // These could include:
        // - Loading cached data
        // - Checking network connectivity
        // - Initializing analytics
        // - Setting up crash reporting
        
        // For now, we'll just add a small delay to ensure smooth transition
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
    }
}
