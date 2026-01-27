# Refactoring Opportunities - Codebase Analysis

This document identifies areas where the codebase can be refactored to reduce hardcoding, eliminate repetition, and improve dynamism.

## 🔴 Critical Issues (High Priority)

### 1. **Hardcoded Colors Everywhere**
**Problem**: Color values are hardcoded throughout the codebase instead of using a centralized color system.

**Examples**:
```swift
// Found in multiple files:
Color(red: 0.0, green: 0.48, blue: 1.0)  // Blue
Color(red: 0.58, green: 0.0, blue: 1.0)  // Purple
Color(red: 0.15, green: 0.15, blue: 0.2) // Dark text
Color(red: 0.3, green: 0.3, blue: 0.35)  // Secondary text
Color(red: 0.12, green: 0.12, blue: 0.15) // Card background
Color.white.opacity(0.08) // Glassmorphic fill
```

**Impact**: 
- Hard to maintain theme changes
- Inconsistent colors across views
- No dark/light mode support
- Design system violations

**Solution**: Create `ColorSystem.swift` in UIComponents package:
```swift
public struct AppColors {
    // Primary
    public static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    public static let primaryPurple = Color(red: 0.58, green: 0.0, blue: 1.0)
    
    // Text
    public static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.2)
    public static let textSecondary = Color(red: 0.3, green: 0.3, blue: 0.35)
    
    // Backgrounds
    public static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.15)
    public static let glassFill = Color.white.opacity(0.08)
    
    // Gradients
    public static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryBlue, primaryPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
```

**Files Affected**: 
- `AgentIntroView.swift` (20+ instances)
- `AgentChatView.swift` (10+ instances)
- `PaywallView.swift`
- `WelcomeStepView.swift`
- `TypingKeyboardView.swift`

---

### 2. **Repeated Glassmorphic Card Pattern**
**Problem**: The same glassmorphic styling code is duplicated across multiple views.

**Pattern Repeated**:
```swift
.background(
    Color.white.opacity(0.08),
    in: RoundedRectangle(cornerRadius: X)
)
.overlay(
    RoundedRectangle(cornerRadius: X)
        .stroke(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 1
        )
)
.shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
```

**Solution**: Create reusable view modifier:
```swift
// In UIComponents/Modifiers/BackgroundModifiers.swift
extension View {
    func glassmorphicCard(
        cornerRadius: CGFloat,
        opacity: CGFloat = 0.08,
        shadowRadius: CGFloat = 15
    ) -> some View {
        self
            .background(
                Color.white.opacity(opacity),
                in: RoundedRectangle(cornerRadius: cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: shadowRadius, x: 0, y: 8)
    }
}
```

**Files Affected**:
- `AgentIntroView.swift` (tips section, buttons)
- `AgentChatView.swift` (message bubbles)
- `PaywallView.swift` (price cards)
- `WelcomeStepView.swift`

---

### 3. **Duplicate Views: FullAccessRequiredView & LockedView**
**Problem**: These two views are 95% identical - only text content differs.

**Current**: Two separate files with duplicated code (~90 lines each)

**Solution**: Create a single reusable component:
```swift
struct StatusView: View {
    let icon: String
    let title: String
    let subtitle: String
    let buttonText: String
    let buttonAction: () -> Void
    let footerText: String
    
    // Shared implementation
}
```

**Files to Refactor**:
- `FullAccessRequiredView.swift` → Delete
- `LockedView.swift` → Refactor to use `StatusView`

---

### 4. **Hardcoded Font Sizes (Non-Responsive)**
**Problem**: Many views use fixed font sizes without ResponsiveSystem.

**Examples**:
```swift
// ❌ BAD - Hardcoded
.font(.system(size: 48, weight: .medium))
.font(.system(size: 20, weight: .semibold))
.font(.system(size: 15, weight: .regular))
.font(.system(size: 14, weight: .regular))  // Used 5+ times in AgentIntroView
.font(.system(size: 12, weight: .regular))

// ✅ GOOD - Responsive
.font(.system(
    size: ResponsiveSystem.value(extraSmall: 20, small: 22, standard: 24),
    weight: .semibold
))
```

**Files Affected**:
- `FullAccessRequiredView.swift` (all fonts hardcoded)
- `LockedView.swift` (all fonts hardcoded)
- `AgentIntroView.swift` (14pt used 5+ times)
- `AgentKeyboardView.swift` (18pt hardcoded)
- `SuggestionBarView.swift` (16pt hardcoded)
- `EmojiKeyboardView.swift` (20pt hardcoded)

**Solution**: Create typography system:
```swift
public struct Typography {
    public static func display(size: DisplaySize) -> Font {
        let fontSize = ResponsiveSystem.value(
            extraSmall: size.extraSmall,
            small: size.small,
            standard: size.standard
        )
        return .system(size: fontSize, weight: size.weight, design: .default)
    }
    
    public enum DisplaySize {
        case largeIcon, heading, body, caption
        
        var extraSmall: CGFloat {
            switch self {
            case .largeIcon: return 42
            case .heading: return 18
            case .body: return 13
            case .caption: return 11
            }
        }
        // ... small and standard values
    }
}
```

---

## 🟡 Medium Priority Issues

### 5. **Repeated Button Styling**
**Problem**: Same button gradient and styling code repeated.

**Pattern**:
```swift
.background(
    LinearGradient(
        colors: [Color.orange, Color.orange.opacity(0.85)],
        startPoint: .leading,
        endPoint: .trailing
    )
)
.cornerRadius(12)
.frame(height: 50)
```

**Solution**: Create `ActionButton` component (already exists but not used consistently)

**Files Affected**:
- `FullAccessRequiredView.swift`
- `LockedView.swift`
- `AgentIntroView.swift` (AI button)

---

### 6. **Magic Numbers for Sizing**
**Problem**: Hardcoded corner radius, padding, and spacing values.

**Examples**:
```swift
.cornerRadius(8)  // Used in TypingKeyboardView keys
.cornerRadius(12)  // Used in FullAccessRequiredView, LockedView
.frame(height: 44) // Header height - used 5+ times
.frame(height: 50) // Button height - used 3+ times
.padding(.horizontal, 24) // Repeated everywhere
```

**Solution**: Extend SpacingSystem or create SizingSystem:
```swift
public struct Sizing {
    public static var headerHeight: CGFloat {
        ResponsiveSystem.value(extraSmall: 40, small: 42, standard: 44)
    }
    
    public static var buttonHeight: CGFloat {
        ResponsiveSystem.value(extraSmall: 46, small: 48, standard: 50)
    }
    
    public static var cornerRadius: CornerRadius {
        CornerRadius()
    }
    
    public struct CornerRadius {
        public var small: CGFloat { ResponsiveSystem.value(extraSmall: 8, small: 10, standard: 12) }
        public var medium: CGFloat { ResponsiveSystem.value(extraSmall: 14, small: 16, standard: 18) }
        public var large: CGFloat { ResponsiveSystem.value(extraSmall: 18, small: 20, standard: 24) }
    }
}
```

---

### 7. **Repeated Animation Patterns**
**Problem**: Same spring animation code duplicated.

**Pattern**:
```swift
withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
    // ...
}
```

**Solution**: Create animation constants:
```swift
public struct AppAnimations {
    public static var logoEntrance: Animation {
        .spring(response: 0.6, dampingFraction: 0.65)
    }
    
    public static var contentEntrance: Animation {
        .spring(response: 0.6, dampingFraction: 0.75)
    }
    
    public static var buttonPress: Animation {
        .spring(response: 0.3, dampingFraction: 0.7)
    }
}
```

**Files Affected**:
- `AgentIntroView.swift`
- `SplashScreenView.swift`
- `WelcomeStepView.swift`

---

### 8. **Logo Loading Logic Duplication**
**Problem**: `loadLogoImage()` exists in both `AgentIntroView` and `AgentChatView` (now static but still duplicated).

**Solution**: Move to shared utility:
```swift
// In UIComponents or SharedCore
public struct LogoLoader {
    public static func load() -> UIImage? {
        // Shared implementation
    }
}
```

---

### 9. **Non-Responsive Icon Sizes**
**Problem**: Some icons use fixed sizes.

**Examples**:
```swift
Image(systemName: "sparkles")
    .font(.system(size: 18, weight: .medium))  // Fixed
```

**Solution**: Use ResponsiveSystem for all icons.

---

## 🟢 Low Priority (Nice to Have)

### 10. **Repeated Shadow Patterns**
**Problem**: Multi-layer shadow code repeated.

**Pattern**:
```swift
.shadow(color: Color.black.opacity(0.5), radius: 50, x: 0, y: 25)
.shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 15)
```

**Solution**: Create shadow modifier extension.

---

### 11. **Hardcoded Spacing Values**
**Problem**: Some views use magic numbers for spacing instead of SpacingSystem.

**Solution**: Always use `Spacing.base`, `Spacing.lg`, etc.

---

### 12. **Repeated Gradient Definitions**
**Problem**: Primary gradient defined multiple times.

**Solution**: Use `AppColors.primaryGradient` everywhere.

---

## 📊 Refactoring Priority Matrix

| Issue | Impact | Effort | Priority |
|-------|--------|--------|----------|
| Hardcoded Colors | 🔴 High | Medium | **1** |
| Glassmorphic Pattern | 🔴 High | Low | **2** |
| Duplicate Views | 🟡 Medium | Low | **3** |
| Hardcoded Fonts | 🟡 Medium | Medium | **4** |
| Button Styling | 🟡 Medium | Low | **5** |
| Magic Numbers | 🟡 Medium | Low | **6** |
| Animations | 🟢 Low | Low | **7** |
| Logo Loading | 🟢 Low | Low | **8** |

---

## 🎯 Recommended Refactoring Order

1. **Week 1**: Create `ColorSystem.swift` and `Typography.swift` in UIComponents
2. **Week 2**: Replace all hardcoded colors and fonts
3. **Week 3**: Create glassmorphic modifier and replace patterns
4. **Week 4**: Refactor duplicate views and create shared components
5. **Week 5**: Add sizing system and replace magic numbers
6. **Week 6**: Consolidate animations and other utilities

---

## 📝 Notes

- All refactoring should maintain existing functionality
- Test on all screen sizes after each change
- Update design system documentation as you go
- Consider creating a migration guide for future changes
