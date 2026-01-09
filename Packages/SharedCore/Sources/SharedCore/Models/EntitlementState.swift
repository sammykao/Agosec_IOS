import Foundation

public struct EntitlementState: Codable, Equatable {
    public let isActive: Bool
    public let expiresAt: Date?
    public let productId: String?
    
    public init(isActive: Bool, expiresAt: Date? = nil, productId: String? = nil) {
        self.isActive = isActive
        self.expiresAt = expiresAt
        self.productId = productId
    }
    
    public var isValid: Bool {
        guard isActive else { return false }
        guard let expiresAt = expiresAt else { return true }
        return Date() < expiresAt
    }
}

public enum SubscriptionTier: String, CaseIterable {
    case basic = "basic"
    case pro = "pro"
    
    public var productId: String {
        switch self {
        case .basic: "io.agosec.keyboard.basic"
        case .pro: "io.agosec.keyboard.pro"
        }   
    }
}