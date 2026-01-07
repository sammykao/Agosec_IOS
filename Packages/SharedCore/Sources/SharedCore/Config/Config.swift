import Foundation

public struct Config {
    public static let shared = Config()
    
    public let backendBaseUrl: String
    public let subscriptionProductId: String
    public let environment: Environment
    public let featureFlags: FeatureFlags
    
    public enum Environment: String, Codable {
        case development = "dev"
        case staging = "stage"
        case production = "prod"
    }
    
    private init() {
        let bundle = Bundle.main
        
        self.backendBaseUrl = bundle.infoDictionary?["BACKEND_BASE_URL"] as? String ?? "https://api.agosec.com"
        self.subscriptionProductId = bundle.infoDictionary?["SUBSCRIPTION_PRODUCT_ID"] as? String ?? "com.agosec.keyboard.pro"
        
        if let envString = bundle.infoDictionary?["ENV"] as? String,
           let env = Environment(rawValue: envString) {
            self.environment = env
        } else {
            self.environment = .production
        }
        
        let photosEnabled = bundle.infoDictionary?["FEATURE_AGENT_PHOTOS_ENABLED"] as? Bool ?? true
        let maxScreenshots = bundle.infoDictionary?["MAX_SCREENSHOTS_PER_IMPORT"] as? Int ?? 5
        let maxContext = bundle.infoDictionary?["MAX_CONTEXT_CHARS"] as? Int ?? 20000
        let maxTurns = bundle.infoDictionary?["MAX_TURNS_SENT"] as? Int ?? 12
        
        self.featureFlags = FeatureFlags(
            agentPhotosEnabled: photosEnabled,
            maxScreenshotsPerImport: maxScreenshots,
            maxContextChars: maxContext,
            maxTurnsSent: maxTurns
        )
    }
}