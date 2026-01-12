# Agosec Design System

This document defines the design system and UI guidelines for the Agosec iOS app. **All AI assistants working on this project should follow these guidelines.**

## Design Framework

**Framework**: SwiftUI (iOS 15.0+)
- Use native SwiftUI components and modifiers
- Prefer declarative UI patterns
- Leverage SwiftUI's built-in animations and transitions

## Core Design Principles

1. **Full-Screen Layout**: All screens MUST extend to full iPhone height
   - Use `.ignoresSafeArea(.all)` on background elements
   - Use `.frame(maxWidth: .infinity, maxHeight: .infinity)` on main containers
   - Never use `NavigationView` wrapper that constrains height (use `ZStack` with full-frame instead)

2. **Light, Modern Theme**: Clean, minimal aesthetic with subtle gradients
3. **Physics-Based Animations**: Use spring animations for natural, bouncy motion
4. **Consistent Spacing**: Use standardized spacing values
5. **Accessibility**: Support Dynamic Type and accessibility features

---

## Color Palette

### Primary Colors
```swift
// Light Background Gradient (Primary)
Color(red: 0.98, green: 0.98, blue: 1.0)    // Very light blue-white
Color(red: 0.95, green: 0.96, blue: 0.98)   // Light blue-gray
Color(red: 0.97, green: 0.97, blue: 0.99)   // Light gray-blue

// Text Colors
Color(red: 0.15, green: 0.15, blue: 0.2)    // Dark gray-blue (primary text)
Color.gray                                   // Secondary text
Color.white                                  // Text on colored backgrounds

// Accent Colors
Color.blue                                   // Primary accent
Color.purple                                 // Secondary accent
```

### Usage Guidelines
- **Backgrounds**: Always use the light gradient for screens
- **Text**: Use dark gray-blue for primary text, gray for secondary
- **Accents**: Use blue for primary actions, purple for secondary elements
- **Shadows**: Use subtle black shadows with low opacity (0.05-0.1)

---

## Typography

### Font System
```swift
// Headings
.font(.system(size: 36, weight: .semibold, design: .default))  // Large headings
.font(.system(size: 28, weight: .semibold, design: .default))  // Medium headings
.font(.system(size: 24, weight: .bold, design: .default))      // Section headings

// Body Text
.font(.system(size: 18, weight: .medium, design: .default))     // Body text
.font(.system(size: 16, weight: .regular, design: .default))    // Regular text
.font(.system(size: 14, weight: .regular, design: .default))   // Small text
```

### Typography Rules
- **Always use `.default` design** (San Francisco) - never use `.rounded` or `.serif`
- Use `.semibold` for headings, `.medium` for emphasis, `.regular` for body
- Support Dynamic Type with relative sizing where appropriate
- Line spacing: Use default SwiftUI line spacing (no manual adjustments)

---

## Spacing System

### Standard Spacing Values
```swift
// Padding
.padding(8)      // Tight spacing (buttons, icons)
.padding(12)     // Compact spacing
.padding(16)     // Standard spacing
.padding(24)     // Comfortable spacing
.padding(32)     // Generous spacing
.padding(40)     // Large spacing (screen edges)

// VStack/HStack Spacing
VStack(spacing: 8)   // Tight vertical spacing
VStack(spacing: 16)  // Standard vertical spacing
VStack(spacing: 24)  // Comfortable vertical spacing
VStack(spacing: 32)  // Generous vertical spacing
```

### Layout Rules
- **Screen Edges**: Use minimum 24px horizontal padding, 40px for bottom safe area
- **Component Spacing**: Use 16-24px between major UI elements
- **Content Width**: Max content width should be responsive, use `min(geometry.size.width * 0.9, 400)` for constrained content

---

## Component Guidelines

### Buttons
```swift
// Primary Action Button
ActionButton(title: "Get Started", action: { })
  .padding(.horizontal, 24)

// Button Styling
- Rounded corners: 12px
- Full width with horizontal padding
- Use ActionButton component from UIComponents package
```

### Cards/Containers
```swift
.background(Color.gray.opacity(0.1))
.cornerRadius(12)
.padding()
```

### Images/Logos
```swift
// Logo Loading Pattern
Group {
    if let uiImage = UIImage(named: "agosec_logo") {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    } else {
        Image(systemName: "app.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.gray)
    }
}
.frame(width: 160, height: 160)
```

---

## Animation Guidelines

### Spring Animations (Preferred)
```swift
// Logo/Element Entrance
withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
    // Animation code
}

// Button/Interactive Elements
withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
    // Animation code
}

// Continuous Animations
withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
    // Animation code
}
```

### Animation Rules
- **Entrance**: Use spring animations with response 0.6-0.8, damping 0.5-0.7
- **Continuous**: Use easeInOut with 2-3 second duration for floating/breathing effects
- **Transitions**: Use `.opacity` and `.scale` for screen transitions
- **Stagger**: Delay animations by 0.2-0.3 seconds for sequential effects

---

## Layout Patterns

### Full-Screen Screen Pattern (REQUIRED)
```swift
var body: some View {
    ZStack {
        // Background
        LinearGradient(...)
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        // Content
        VStack {
            // Content here
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea(.all)
}
```

### Onboarding Screen Pattern
```swift
GeometryReader { geometry in
    VStack(spacing: 0) {
        Spacer()
        
        // Main content (centered)
        VStack(spacing: 32) {
            // Logo, text, etc.
        }
        
        Spacer()
        
        // Bottom actions
        VStack {
            // Buttons, indicators
        }
        .padding(.bottom, max(geometry.size.height * 0.1, 40))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
.frame(maxWidth: .infinity, maxHeight: .infinity)
.ignoresSafeArea(.all)
```

### Critical Layout Rules
1. **NEVER use NavigationView** for full-screen screens - it constrains height
2. **ALWAYS use `.ignoresSafeArea(.all)`** on background and root container
3. **ALWAYS use `.frame(maxWidth: .infinity, maxHeight: .infinity)`** on main containers
4. **Use GeometryReader** for responsive sizing when needed
5. **Test on different iPhone sizes** to ensure full-height coverage

---

## Shadows & Depth

### Shadow Guidelines
```swift
// Subtle shadows for depth
.shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
.shadow(color: Color.blue.opacity(0.1), radius: 15, x: 0, y: 5)

// Text shadows
.shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
```

### Shadow Rules
- Use low opacity (0.05-0.1) for subtle depth
- Combine black and colored shadows for logos/elevated elements
- Keep radius between 2-20px depending on element size

---

## Logo & Branding

### Logo Usage
- **Asset Name**: `agosec_logo` (from Assets.xcassets)
- **Loading Pattern**: Always use `UIImage(named:)` with fallback
- **Sizing**: Standard 160x160 for splash/welcome, scale proportionally
- **Animation**: Spring entrance with subtle floating animation

### App Icon
- **Location**: `AppIcon.appiconset` in Assets.xcassets
- **Sizes**: All required sizes generated from logo
- **Display Name**: "Agosec" (not "Agosec Keyboard")

---

## Component Library

### Available Components (UIComponents Package)
- `ActionButton`: Primary action button with consistent styling
- `LoadingOverlay`: Full-screen loading indicator
- `SplashScreenView`: Animated splash screen with logo
- `ToastOverlay`: Toast notification system
- `PageIndicator`: Onboarding pagination dots

### Usage
```swift
import UIComponents

ActionButton(title: "Continue", action: { })
SplashScreenView(logoName: "agosec_logo", appName: "Agosec")
```

---

## Accessibility

### Requirements
- Support Dynamic Type (use relative sizing where possible)
- Provide accessibility labels for images and icons
- Ensure sufficient color contrast (WCAG AA minimum)
- Support VoiceOver navigation

### Implementation
```swift
.accessibilityLabel("Agosec logo")
.accessibilityHint("Welcome screen")
```

---

## Common Patterns

### Screen Transition
```swift
.transition(.asymmetric(
    insertion: .opacity.combined(with: .scale(scale: 0.95)),
    removal: .opacity
))
.animation(.easeInOut(duration: 0.4), value: state)
```

### Responsive Sizing
```swift
.frame(width: min(geometry.size.width * 0.4, 160))
.font(.system(size: min(geometry.size.width * 0.06, 28), ...))
```

### Conditional Rendering
```swift
Group {
    if condition {
        // Content
    } else {
        // Fallback
    }
}
```

---

## Anti-Patterns (DO NOT USE)

❌ **NavigationView** for full-screen layouts
❌ **Hard-coded colors** - use the color palette
❌ **Fixed font sizes** without responsive alternatives
❌ **Screens that don't extend to full height**
❌ **Rounded design** font - use `.default`
❌ **Heavy shadows** - keep opacity low
❌ **Complex custom animations** - prefer spring physics

---

## File Organization

### Component Location
- **UI Components**: `Packages/UIComponents/Sources/UIComponents/`
- **Feature Views**: `AgosecApp/Features/[FeatureName]/`
- **Shared Assets**: `AgosecApp/Resources/Assets.xcassets/`

### Naming Conventions
- Views: `[Name]View.swift` (e.g., `WelcomeStepView.swift`)
- Components: `[Name].swift` (e.g., `ActionButton.swift`)
- Assets: lowercase with underscores (e.g., `agosec_logo.png`)

---

## Testing Checklist

Before considering a screen complete, verify:
- [ ] Screen extends to full iPhone height (no black bars)
- [ ] Logo displays correctly (with fallback if missing)
- [ ] Animations are smooth and use spring physics
- [ ] Colors match the design system palette
- [ ] Typography uses system default font
- [ ] Spacing follows the spacing system
- [ ] Shadows are subtle and appropriate
- [ ] Works on different iPhone sizes (SE, Pro, Pro Max)
- [ ] Accessibility labels are present

---

## Quick Reference

### Full-Screen Template
```swift
struct MyScreenView: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.97, green: 0.97, blue: 0.99)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Content
            VStack {
                // Your content here
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
}
```

---

**Last Updated**: 2024
**Framework**: SwiftUI (iOS 15.0+)
**Maintained By**: Agosec Development Team
