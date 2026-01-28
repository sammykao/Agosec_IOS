import SwiftUI

// MARK: - Spacing Utilities (Tailwind-like)

public extension View {
    /// Padding utilities
    func p(_ value: CGFloat) -> some View {
        self.padding(value)
    }

    func px(_ value: CGFloat) -> some View {
        self.padding(.horizontal, value)
    }

    func py(_ value: CGFloat) -> some View {
        self.padding(.vertical, value)
    }

    func pt(_ value: CGFloat) -> some View {
        self.padding(.top, value)
    }

    func pb(_ value: CGFloat) -> some View {
        self.padding(.bottom, value)
    }

    func pl(_ value: CGFloat) -> some View {
        self.padding(.leading, value)
    }

    func pr(_ value: CGFloat) -> some View {
        self.padding(.trailing, value)
    }

    /// Standard spacing values from design system
    func p8() -> some View { self.padding(8) }
    func p12() -> some View { self.padding(12) }
    func p16() -> some View { self.padding(16) }
    func p24() -> some View { self.padding(24) }
    func p32() -> some View { self.padding(32) }
    func p40() -> some View { self.padding(40) }

    func px24() -> some View { self.px(24) }
    func px40() -> some View { self.px(40) }
    func py16() -> some View { self.py(16) }
    func py24() -> some View { self.py(24) }
}
