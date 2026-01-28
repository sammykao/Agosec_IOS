import SwiftUI

// MARK: - Background Utilities

public extension View {
    /// Standard light gradient background from design system
    func lightGradientBackground() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.97, green: 0.97, blue: 0.99)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    /// Subtle shadow for depth
    func subtleShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }

    /// Card shadow
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
