import Foundation

/// Build configuration for development and testing modes
public enum BuildMode {
    /// When true, all network calls use mock services instead of real backend
    /// Can be enabled via:
    /// 1. Info.plist: MOCK_BACKEND_ENABLED = true
    /// 2. Environment variable: MOCK_BACKEND = true
    /// Only works in DEBUG builds
    public static var isMockBackend: Bool {
        #if DEBUG
        let fromPlist = Bundle.main.infoDictionary?["MOCK_BACKEND_ENABLED"] as? Bool ?? false
        let fromEnv = ProcessInfo.processInfo.environment["MOCK_BACKEND"] == "true"
        return fromPlist || fromEnv
        #else
        return false
        #endif
    }
    
    /// Simulated network delay for mock responses (in seconds)
    /// This simulates real network latency for more realistic testing
    public static var mockNetworkDelay: TimeInterval {
        return 1.5
    }
}

