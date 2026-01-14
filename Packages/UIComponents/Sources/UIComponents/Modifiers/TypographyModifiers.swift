import SwiftUI

// MARK: - Typography Utilities

public extension View {
    /// Heading styles from design system
    func headingLarge() -> some View {
        self.font(.system(size: 36, weight: .semibold, design: .default))
    }
    
    func headingMedium() -> some View {
        self.font(.system(size: 28, weight: .semibold, design: .default))
    }
    
    func headingSmall() -> some View {
        self.font(.system(size: 24, weight: .bold, design: .default))
    }
    
    /// Body text styles
    func bodyLarge() -> some View {
        self.font(.system(size: 18, weight: .medium, design: .default))
    }
    
    func bodyRegular() -> some View {
        self.font(.system(size: 16, weight: .regular, design: .default))
    }
    
    func bodySmall() -> some View {
        self.font(.system(size: 14, weight: .regular, design: .default))
    }
    
    /// Text colors
    func textPrimary() -> some View {
        self.foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
    }
    
    func textSecondary() -> some View {
        self.foregroundColor(.gray)
    }
    
    func textAccent() -> some View {
        self.foregroundColor(.blue)
    }
}
