import UIKit

public extension UIImpactFeedbackGenerator {
    static func safeImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        #if targetEnvironment(simulator)
        // Haptic feedback not available in simulator - silently skip
        #else
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
}
