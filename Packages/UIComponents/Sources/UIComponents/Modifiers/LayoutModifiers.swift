import SwiftUI

// MARK: - Layout Utilities

public extension View {
    /// Full width
    func wFull() -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    /// Full height
    func hFull() -> some View {
        self.frame(maxHeight: .infinity)
    }
    
    /// Full screen (width and height)
    func fullScreen() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Ignore safe area (for full-screen layouts)
    func ignoreSafeArea() -> some View {
        self.ignoresSafeArea(.all)
    }
    
    /// Center content
    func center() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Rounded corners with standard radius
    func rounded(_ radius: CGFloat = 12) -> some View {
        self.cornerRadius(radius)
    }
    
    /// Standard card style
    func cardStyle() -> some View {
        self
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
