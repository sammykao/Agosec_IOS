import Foundation

public enum KeyboardMode: Codable {
    case normal
    case agent
}

public struct KeyboardState: Codable {
    public var currentMode: KeyboardMode
    public var isExpanded: Bool
    public var hasFullAccess: Bool
    public var entitlementState: EntitlementState

    public init(
        currentMode: KeyboardMode = .normal,
        isExpanded: Bool = false,
        hasFullAccess: Bool = false,
        entitlementState: EntitlementState = EntitlementState(isActive: false)
    ) {
        self.currentMode = currentMode
        self.isExpanded = isExpanded
        self.hasFullAccess = hasFullAccess
        self.entitlementState = entitlementState
    }

    public var isLocked: Bool {
        return !entitlementState.isValid
    }
}
