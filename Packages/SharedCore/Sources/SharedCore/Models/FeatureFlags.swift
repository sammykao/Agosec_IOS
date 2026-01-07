import Foundation

public struct FeatureFlags: Codable {
    public let agentPhotosEnabled: Bool
    public let maxScreenshotsPerImport: Int
    public let maxContextChars: Int
    public let maxTurnsSent: Int
    
    public init(
        agentPhotosEnabled: Bool = true,
        maxScreenshotsPerImport: Int = 5,
        maxContextChars: Int = 20000,
        maxTurnsSent: Int = 12
    ) {
        self.agentPhotosEnabled = agentPhotosEnabled
        self.maxScreenshotsPerImport = maxScreenshotsPerImport
        self.maxContextChars = maxContextChars
        self.maxTurnsSent = maxTurnsSent
    }
}