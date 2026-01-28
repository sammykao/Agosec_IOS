import SwiftUI
import UIKit

/// Centralized responsive system for screen size detection
/// Provides consistent screen size categorization across the app
public struct ResponsiveSystem {
    private static let screenWidth = UIScreen.main.bounds.width
    private static let screenHeight = UIScreen.main.bounds.height

    // MARK: - Screen Size Categories

    /// Extra small screens (iPhone SE 1st/2nd gen) - width < 360px
    public static var isExtraSmallScreen: Bool {
        screenWidth < 360
    }

    /// Small screens (iPhone SE 3rd gen, iPhone 8, iPhone mini) - width < 380px
    public static var isSmallScreen: Bool {
        screenWidth < 380
    }

    /// Short screens (older iPhones, iPhone SE) - height < 800px
    public static var isShortScreen: Bool {
        screenHeight < 800
    }

    /// Standard screens (iPhone 14, iPhone 15) - 380px <= width < 430px
    public static var isStandardScreen: Bool {
        screenWidth >= 380 && screenWidth < 430
    }

    /// Large screens (iPhone Pro Max, iPhone Plus) - width >= 430px
    public static var isLargeScreen: Bool {
        screenWidth >= 430
    }

    // MARK: - Responsive Values

    /// Get responsive value based on screen size
    /// - Parameters:
    ///   - extraSmall: Value for extra small screens (iPhone SE)
    ///   - small: Value for small screens (iPhone mini)
    ///   - standard: Value for standard screens (default)
    /// - Returns: Appropriate value for current screen size
    public static func value<T>(
        extraSmall: T,
        small: T,
        standard: T
    ) -> T {
        if isExtraSmallScreen {
            return extraSmall
        } else if isSmallScreen {
            return small
        } else {
            return standard
        }
    }

    /// Get responsive value with large screen option
    public static func value<T>(
        extraSmall: T,
        small: T,
        standard: T,
        large: T
    ) -> T {
        if isExtraSmallScreen {
            return extraSmall
        } else if isSmallScreen {
            return small
        } else if isLargeScreen {
            return large
        } else {
            return standard
        }
    }

    /// Scale a base value based on screen size
    /// - Parameters:
    ///   - base: Base value for standard screens
    ///   - extraSmallScale: Scale factor for extra small screens (default 0.85)
    ///   - smallScale: Scale factor for small screens (default 0.9)
    /// - Returns: Scaled value
    public static func scale(
        _ base: CGFloat,
        extraSmallScale: CGFloat = 0.85,
        smallScale: CGFloat = 0.9
    ) -> CGFloat {
        if isExtraSmallScreen {
            return base * extraSmallScale
        } else if isSmallScreen {
            return base * smallScale
        } else {
            return base
        }
    }
}

/// View extension for easy access to responsive system
public extension View {
    /// Apply responsive padding
    func responsivePadding(
        _ edges: Edge.Set = .all,
        extraSmall: CGFloat,
        small: CGFloat,
        standard: CGFloat
    ) -> some View {
        self.padding(edges, ResponsiveSystem.value(
            extraSmall: extraSmall,
            small: small,
            standard: standard
        ))
    }

    /// Apply responsive font size
    func responsiveFont(
        extraSmall: CGFloat,
        small: CGFloat,
        standard: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> some View {
        self.font(.system(
            size: ResponsiveSystem.value(
                extraSmall: extraSmall,
                small: small,
                standard: standard
            ),
            weight: weight,
            design: design
        ))
    }
}
