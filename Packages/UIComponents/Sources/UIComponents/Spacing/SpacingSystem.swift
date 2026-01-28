import SwiftUI

/// Tailwind-like responsive spacing system for SwiftUI
/// Provides consistent spacing that scales based on screen size
public struct Spacing {
    // Base spacing scale (similar to Tailwind)
    // Scales down on smaller screens
    private static func scale(_ base: CGFloat) -> CGFloat {
        if ResponsiveSystem.isExtraSmallScreen {
            return base * 0.85  // 15% reduction for very small screens
        } else if ResponsiveSystem.isSmallScreen {
            return base * 0.9   // 10% reduction for small screens
        }
        return base
    }

    // Spacing values (Tailwind-like scale)
    // swiftlint:disable identifier_name
    public static var xs: CGFloat { scale(4) }      // 4px → 3.4px (extra small) / 3.6px (small)
    public static var sm: CGFloat { scale(8) }    // 8px → 6.8px / 7.2px
    public static var md: CGFloat { scale(12) }    // 12px → 10.2px / 10.8px
    public static var base: CGFloat { scale(16) }  // 16px → 13.6px / 14.4px
    public static var lg: CGFloat { scale(20) }    // 20px → 17px / 18px
    public static var xl: CGFloat { scale(24) }  // 24px → 20.4px / 21.6px
    // swiftlint:enable identifier_name
    public static var xl2: CGFloat { scale(28) }  // 28px → 23.8px / 25.2px
    public static var xl3: CGFloat { scale(32) }  // 32px → 27.2px / 28.8px
    public static var xl4: CGFloat { scale(40) }  // 40px → 34px / 36px
    public static var xl5: CGFloat { scale(48) }  // 48px → 40.8px / 43.2px
    public static var xl6: CGFloat { scale(64) }  // 64px → 54.4px / 57.6px

    // Compact spacing for very tight layouts
    public static var compact: CGFloat {
        ResponsiveSystem.isExtraSmallScreen ? 2 : (ResponsiveSystem.isSmallScreen ? 3 : 4)
    }

    // Standard spacing for most layouts
    public static var standard: CGFloat { base }

    // Generous spacing for sections
    public static var generous: CGFloat { xl3 }

    // Screen edge padding
    public static var edgePadding: CGFloat {
        ResponsiveSystem.value(extraSmall: 16, small: 20, standard: 24)
    }

    // Section spacing
    public static var sectionSpacing: CGFloat {
        ResponsiveSystem.isShortScreen ? xl2 : xl3
    }
}

/// View extension for easy spacing access
public extension View {
    /// Apply responsive padding using spacing system
    func spacingPadding(_ edges: Edge.Set = .all, _ amount: CGFloat) -> some View {
        self.padding(edges, amount)
    }

    /// Padding using spacing system values
    func spacing(_ edges: Edge.Set = .all, _ spacing: CGFloat) -> some View {
        self.padding(edges, spacing)
    }
}
