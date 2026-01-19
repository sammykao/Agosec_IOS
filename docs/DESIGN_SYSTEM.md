# Agosec Design System - Modern & Innovative UI

This document defines the cutting-edge design system and UI guidelines for the Agosec iOS app. **All AI assistants working on this project should follow these guidelines.**

## Design Framework

**Framework**: SwiftUI (iOS 15.0+)
- Use native SwiftUI components and modifiers
- Prefer declarative UI patterns
- Leverage SwiftUI's built-in animations and transitions
- Embrace modern design trends: glassmorphism, bold typography, micro-interactions

## Core Design Principles

1. **Full-Screen Layout**: All screens MUST extend to full iPhone height
   - Use `.ignoresSafeArea(.all)` on background elements
   - Use `.frame(maxWidth: .infinity, maxHeight: .infinity)` on main containers
   - Never use `NavigationView` wrapper that constrains height (use `ZStack` with full-frame instead)

2. **Modern Glassmorphic Aesthetic**: Frosted glass effects, translucent panels, soft depth layers
3. **Bold Typography**: Expressive, large headings with clear hierarchy
4. **Micro-Interactions**: Every interaction should provide delightful feedback
5. **Physics-Based Animations**: Use spring animations for natural, bouncy motion
6. **Consistent Spacing**: Use standardized spacing values
7. **Accessibility**: Support Dynamic Type, dark mode, and accessibility features

---

## Color Palette

### Primary Colors (Dark Theme - Default)
```swift
// Dark Background (Primary - Used for all screens)
Color(red: 0.05, green: 0.05, blue: 0.08)     // Deep dark base
Color(red: 0.08, green: 0.08, blue: 0.12)    // Dark blue-gray
Color(red: 0.06, green: 0.06, blue: 0.1)     // Dark accent

// Container/Card backgrounds
Color(red: 0.12, green: 0.12, blue: 0.15)    // Dark card background
Color.white.opacity(0.08)                     // Glassmorphic card fill
Color.white.opacity(0.1)                      // Slightly brighter card

// Text Colors (Dark Theme)
Color.white                                   // Primary text
Color(red: 0.9, green: 0.9, blue: 0.95)      // Heading text
Color(red: 0.85, green: 0.85, blue: 0.9)     // Body text
Color(red: 0.7, green: 0.7, blue: 0.75)      // Secondary text
Color(red: 0.6, green: 0.6, blue: 0.65)      // Tertiary/hint text

// Vibrant Accent Colors
Color(red: 0.0, green: 0.48, blue: 1.0)      // Vibrant blue (primary)
Color(red: 0.58, green: 0.0, blue: 1.0)      // Vibrant purple (secondary)
Color(red: 0.0, green: 0.78, blue: 0.33)     // Success green
Color(red: 1.0, green: 0.58, blue: 0.0)      // Warning orange

// Glassmorphic Overlay Colors
Color.white.opacity(0.7)                      // Light glass overlay
Color.white.opacity(0.25)                     // Subtle light glass
Color.black.opacity(0.3)                      // Dark glass overlay
Color.black.opacity(0.15)                     // Subtle dark glass
```

### Usage Guidelines
- **Backgrounds**: Use dark gradient backgrounds as the primary theme
- **Text**: Light text on dark backgrounds for high contrast (WCAG AA minimum)
- **Accents**: Use vibrant blue/purple gradients for emphasis and CTAs
- **Glass Effects**: Use semi-transparent white overlays (0.08-0.15 opacity) on dark
- **Borders**: Use white with low opacity (0.1-0.3) for subtle borders
- **Shadows**: Use darker shadows with higher opacity on dark backgrounds

---

## Typography

### Font System (Bold & Expressive)
```swift
// Display Headings (Splash, Onboarding Titles)
.font(.system(size: 64, weight: .bold, design: .default))    // Hero text
.font(.system(size: 48, weight: .bold, design: .default))    // Large heading
.font(.system(size: 36, weight: .bold, design: .default))    // Section heading

// Body Text
.font(.system(size: 20, weight: .medium, design: .default))  // Emphasized body
.font(.system(size: 18, weight: .regular, design: .default))  // Body text
.font(.system(size: 16, weight: .regular, design: .default))  // Regular text
.font(.system(size: 14, weight: .regular, design: .default)) // Small text
.font(.system(size: 12, weight: .medium, design: .default))  // Caption
```

### Typography Rules
- **Always use `.default` design** (San Francisco) - never use `.rounded` or `.serif`
- **Bold for Impact**: Use `.bold` for headings, `.semibold` for emphasis
- **Generous Line Height**: Add 4-8px extra line spacing for readability
- **Support Dynamic Type**: Use relative sizing where appropriate
- **Letter Spacing**: Use `.tracking()` for display text (0.5-2.0)

---

## Glassmorphism & Depth

### Glassmorphic Panels (Dark Theme)
```swift
// Dark Theme Glass Panel (Primary Style)
.background(
    Color.white.opacity(0.08),
    in: RoundedRectangle(cornerRadius: 24)
)
.overlay(
    RoundedRectangle(cornerRadius: 24)
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
.shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 15)
.shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

// Dark Container for Logo/Icons (when content is white)
Circle()
    .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
    .overlay(
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.3),
                        Color.white.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
    )
    .shadow(color: Color.black.opacity(0.5), radius: 50, x: 0, y: 25)
    .shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 15)
```

### Depth Layers
- **Layer 1 (Base)**: Background gradient
- **Layer 2 (Mid)**: Glassmorphic panels with blur
- **Layer 3 (Top)**: Interactive elements with stronger shadows
- **Elevation**: Use multiple soft shadows for depth perception

---

## Spacing System

### Standard Spacing Values
```swift
// Padding
.padding(4)      // Minimal spacing
.padding(8)      // Tight spacing (icons, small elements)
.padding(12)     // Compact spacing
.padding(16)     // Standard spacing
.padding(24)     // Comfortable spacing
.padding(32)     // Generous spacing
.padding(40)     // Large spacing (screen edges)
.padding(48)     // Extra large spacing

// VStack/HStack Spacing
VStack(spacing: 8)   // Tight vertical spacing
VStack(spacing: 16)  // Standard vertical spacing
VStack(spacing: 24)  // Comfortable vertical spacing
VStack(spacing: 32)  // Generous vertical spacing
VStack(spacing: 40)  // Extra large spacing
```

### Layout Rules
- **Screen Edges**: Use minimum 24px horizontal padding, 40px for bottom safe area
- **Component Spacing**: Use 16-24px between major UI elements
- **Content Width**: Max content width should be responsive, use `min(geometry.size.width * 0.9, 400)` for constrained content
- **Glass Panels**: Add 20-32px padding inside glassmorphic containers

---

## Component Guidelines

### Modern Buttons
```swift
// Primary Action Button (Glassmorphic with Gradient)
Button(action: { }) {
    HStack(spacing: 12) {
        Text("Get Started")
            .font(.system(size: 19, weight: .semibold, design: .default))
        Image(systemName: "arrow.right")
            .font(.system(size: 17, weight: .semibold))
    }
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .frame(height: 60)
    .background(
        ZStack {
            // Gradient base
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.48, blue: 1.0),
                    Color(red: 0.58, green: 0.0, blue: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            // Glassmorphic overlay
            Color.white.opacity(0.1)
        }
    )
    .cornerRadius(20)
    .shadow(color: Color.blue.opacity(0.4), radius: 20, x: 0, y: 10)
    .shadow(color: Color.purple.opacity(0.2), radius: 10, x: 0, y: 5)
}
.buttonStyle(ScaleButtonStyle())

// Secondary Button (Glassmorphic)
Button(action: { }) {
    Text("Skip")
        .font(.system(size: 17, weight: .medium, design: .default))
        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
}
```

### Glassmorphic Cards/Containers
```swift
VStack {
    // Content
}
.padding(24)
.background(
    .ultraThinMaterial,
    in: RoundedRectangle(cornerRadius: 24)
)
.overlay(
    RoundedRectangle(cornerRadius: 24)
        .stroke(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.5),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 1.5
        )
)
.shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
.shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
```

### Images/Logos
```swift
// Logo Loading Pattern with Glassmorphic Container
ZStack {
    // Glassmorphic background
    Circle()
        .fill(.ultraThinMaterial)
        .frame(width: 200, height: 200)
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 40, x: 0, y: 20)
    
    // Logo
    Group {
        if let uiImage = UIImage(named: "agosec_logo") {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "sparkles")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.48, blue: 1.0),
                            Color(red: 0.58, green: 0.0, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    .frame(width: 140, height: 140)
}
```

---

## Animation Guidelines

### Spring Animations (Preferred)
```swift
// Logo/Element Entrance (Bouncy)
withAnimation(.spring(response: 0.6, dampingFraction: 0.65, blendDuration: 0)) {
    // Animation code
}

// Button/Interactive Elements (Snappy)
withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
    // Animation code
}

// Continuous Animations (Smooth)
withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
    // Animation code
}

// Micro-Interactions (Quick Feedback)
withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
    // Button press, hover effects
}
```

### Animation Rules
- **Entrance**: Use spring animations with response 0.4-0.6, damping 0.6-0.8 for snappy feel
- **Continuous**: Use easeInOut with 2-4 second duration for floating/breathing effects
- **Transitions**: Combine `.opacity`, `.scale`, and `.move` for rich transitions
- **Stagger**: Delay animations by 0.1-0.2 seconds for sequential effects
- **Micro-Interactions**: All buttons should have scale/ripple feedback (200-300ms)

### Advanced Transitions
```swift
// Rich Page Transition
.transition(.asymmetric(
    insertion: .opacity
        .combined(with: .scale(scale: 0.9))
        .combined(with: .move(edge: .trailing)),
    removal: .opacity
        .combined(with: .scale(scale: 0.95))
        .combined(with: .move(edge: .leading))
))
.animation(.spring(response: 0.5, dampingFraction: 0.8), value: state)
```

---

## Layout Patterns

### Full-Screen Screen Pattern (REQUIRED)
```swift
var body: some View {
    ZStack {
        // Glassmorphic Background
        modernBackground
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

private var modernBackground: some View {
    ZStack {
        // Base gradient
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.99, green: 0.99, blue: 1.0),
                Color(red: 0.97, green: 0.98, blue: 0.99),
                Color(red: 0.95, green: 0.96, blue: 0.98)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Glassmorphic accent orbs
        floatingGlassOrbs
    }
}
```

### Onboarding Screen Pattern
```swift
GeometryReader { geometry in
    ZStack {
        // Modern background
        modernBackground
        
        VStack(spacing: 0) {
            Spacer()
            
            // Main content in glassmorphic panel
            VStack(spacing: 32) {
                // Icon/Illustration
                // Title (bold, large)
                // Description
            }
            .padding(32)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 32)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 40, x: 0, y: 20)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Bottom actions
            VStack {
                // Buttons, indicators
            }
            .padding(.bottom, max(geometry.size.height * 0.1, 40))
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
.ignoresSafeArea(.all)
```

### Critical Layout Rules
1. **NEVER use NavigationView** for full-screen screens - it constrains height
2. **ALWAYS use `.ignoresSafeArea(.all)`** on background and root container
3. **ALWAYS use `.frame(maxWidth: .infinity, maxHeight: .infinity)`** on main containers
4. **Use GeometryReader** for responsive sizing when needed
5. **Test on different iPhone sizes** to ensure full-height coverage
6. **Apply glassmorphism** to main content panels for depth

---

## Responsiveness Guidelines

All screens MUST be responsive across different iPhone device types. This section defines the rules for building adaptive layouts.

### Device Size Categories
```swift
// Small screens (iPhone SE, iPhone 8, iPhone mini)
geometry.size.width < 380

// Standard screens (iPhone 14, iPhone 15)
geometry.size.width >= 380 && geometry.size.width < 430

// Large screens (iPhone Pro Max, iPhone Plus)
geometry.size.width >= 430
```

### Responsive Font Sizing
**NEVER use fixed font sizes.** Always calculate sizes based on screen dimensions:

```swift
// ❌ BAD - Fixed font size
.font(.system(size: 28, weight: .bold, design: .default))

// ✅ GOOD - Responsive font size with max limit
.font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold, design: .default))
```

#### Font Size Formulas
```swift
// Display/Hero text (splash screens)
min(geometry.size.width * 0.15, 48)    // Max 48pt

// Large headings (screen titles)
min(geometry.size.width * 0.08, 32)    // Max 32pt

// Section headings
min(geometry.size.width * 0.07, 28)    // Max 28pt

// Body text
min(geometry.size.width * 0.045, 18)   // Max 18pt

// Secondary/subtitle text
min(geometry.size.width * 0.043, 17)   // Max 17pt

// Small text/captions
min(geometry.size.width * 0.035, 14)   // Max 14pt

// Tiny text/hints
min(geometry.size.width * 0.033, 13)   // Max 13pt
```

### Responsive Icon & Element Sizing
```swift
// Icon containers (circles, etc.)
let iconSize = min(geometry.size.width * 0.22, 90)
let containerSize = iconSize * 1.15

// Ring/glow effects
let ringBaseSize = min(geometry.size.width * 0.25, 100)

// Logo sizing
let logoSize = min(geometry.size.width * 0.35, 140)
```

### Responsive Spacing
```swift
// Horizontal padding
.padding(.horizontal, geometry.size.width * 0.06)  // ~6% of width
.padding(.horizontal, geometry.size.width * 0.07)  // ~7% of width
.padding(.horizontal, geometry.size.width * 0.08)  // ~8% of width

// Vertical spacing between sections
.padding(.bottom, min(geometry.size.height * 0.04, 32))
.padding(.top, min(geometry.size.height * 0.03, 24))

// Top safe area offset
.frame(height: geometry.size.height * 0.08)  // Push content down
```

### Small Screen Detection Pattern
Always detect small screens and adjust accordingly:

```swift
GeometryReader { geometry in
    let isSmallScreen = geometry.size.width < 380
    
    VStack(spacing: isSmallScreen ? 10 : 14) {
        Text("Title")
            .font(.system(
                size: isSmallScreen ? 24 : 28,
                weight: .bold,
                design: .default
            ))
        
        // Adjust line widths for small screens
        Circle()
            .stroke(lineWidth: isSmallScreen ? 1.5 : 2)
    }
}
```

### Responsive Component Template
```swift
struct ResponsiveCard: View {
    var body: some View {
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.width < 380
            let titleSize = min(geometry.size.width * 0.05, 20)
            let bodySize = min(geometry.size.width * 0.04, 16)
            let padding: CGFloat = isSmallScreen ? 16 : 20
            let spacing: CGFloat = isSmallScreen ? 10 : 14
            
            VStack(spacing: spacing) {
                Text("Title")
                    .font(.system(size: titleSize, weight: .semibold))
                
                Text("Body text that adapts to screen size")
                    .font(.system(size: bodySize, weight: .regular))
            }
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: isSmallScreen ? 14 : 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }
}
```

### Text Truncation & Scaling
Always provide fallback for long text:

```swift
Text("Long Title That Might Not Fit")
    .lineLimit(2)
    .minimumScaleFactor(0.7)
    .multilineTextAlignment(.center)

// For single-line text
Text("Single Line")
    .lineLimit(1)
    .minimumScaleFactor(0.8)
```

### Responsive Button Heights
```swift
// Primary action buttons
.frame(height: min(geometry.size.height * 0.08, 64))

// Secondary buttons
.frame(height: isSmallScreen ? 50 : 56)
```

### ScrollView for Overflow Content
When content might overflow on smaller screens, wrap in ScrollView:

```swift
GeometryReader { geometry in
    ScrollView(showsIndicators: false) {
        VStack {
            // Content
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: geometry.size.height)
    }
}
```

### Responsive Constraints Pattern
Use `max()` and `min()` to constrain values:

```swift
// Ensure minimum spacing
Spacer(minLength: 16)

// Constrain orb positions to screen bounds
.offset(
    x: max(-geometry.size.width * 0.3, min(geometry.size.width * 0.3, xPosition)),
    y: max(-geometry.size.height * 0.3, min(geometry.size.height * 0.3, yPosition))
)

// Responsive element sizing with bounds
.frame(
    width: min(240 + CGFloat(index) * 100, geometry.size.width * 0.7),
    height: min(240 + CGFloat(index) * 100, geometry.size.width * 0.7)
)
```

### Device Testing Checklist
Test on ALL these device sizes:
- [ ] iPhone SE (3rd gen) - 375 x 667 (small)
- [ ] iPhone 13 mini - 375 x 812 (small with notch)
- [ ] iPhone 14 - 390 x 844 (standard)
- [ ] iPhone 15 Pro - 393 x 852 (standard)
- [ ] iPhone 15 Pro Max - 430 x 932 (large)
- [ ] iPhone 15 Plus - 428 x 926 (large)

### Responsiveness Anti-Patterns

❌ **Fixed pixel sizes for fonts, icons, or spacing**
```swift
// BAD
.font(.system(size: 28))
.frame(width: 100, height: 100)
.padding(24)
```

❌ **Hard-coded minimum spacer sizes that break on small screens**
```swift
// BAD
Spacer(minLength: 60)
```

❌ **Fixed message bubble widths**
```swift
// BAD
if isUser { Spacer(minLength: 60) }
```

✅ **Use proportional sizing**
```swift
// GOOD
.font(.system(size: min(geometry.size.width * 0.07, 28)))
.frame(width: min(geometry.size.width * 0.26, 100))
.padding(geometry.size.width * 0.06)
Spacer(minLength: 40)
if isUser { Spacer(minLength: 40) }
```

---

## Shadows & Depth

### Modern Shadow System
```swift
// Multi-layered shadows for depth
.shadow(color: Color.black.opacity(0.15), radius: 40, x: 0, y: 20)  // Large, soft
.shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)  // Medium
.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)   // Small, sharp

// Colored shadows for accent elements
.shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 15)
.shadow(color: Color.purple.opacity(0.2), radius: 15, x: 0, y: 8)

// Text shadows (subtle)
.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
```

### Shadow Rules
- Use multiple layered shadows for realistic depth
- Combine black and colored shadows for branded elements
- Keep opacity low (0.04-0.15) for subtlety
- Larger radius for softer, more diffused shadows

---

## Logo & Branding

### Logo Usage
- **Asset Name**: `agosec_logo` (from Assets.xcassets)
- **Loading Pattern**: Always use `UIImage(named:)` with fallback
- **Sizing**: Standard 160x160 for splash/welcome, scale proportionally
- **Animation**: Spring entrance with subtle floating animation
- **Container**: Use glassmorphic circle or rounded square background

### App Icon
- **Location**: `AppIcon.appiconset` in Assets.xcassets
- **Sizes**: All required sizes generated from logo
- **Display Name**: "Agosec" (not "Agosec Keyboard")
- **Style**: Modern, minimal, glassmorphic effects if appropriate

---

## Component Library

### Available Components (UIComponents Package)
- `ActionButton`: Primary action button with glassmorphic gradient styling
- `LoadingOverlay`: Full-screen loading indicator with modern animations
- `SplashScreenView`: Animated splash screen with glassmorphic effects
- `ToastOverlay`: Toast notification system
- `PageIndicator`: Onboarding pagination with glassmorphic background

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
- Support Dark Mode with proper contrast

### Implementation
```swift
.accessibilityLabel("Agosec logo")
.accessibilityHint("Welcome screen")
.preferredColorScheme(.light)  // Or .dark, or nil for system
```

---

## Common Patterns

### Screen Transition
```swift
.transition(.asymmetric(
    insertion: .opacity
        .combined(with: .scale(scale: 0.9))
        .combined(with: .move(edge: .trailing)),
    removal: .opacity
        .combined(with: .scale(scale: 0.95))
        .combined(with: .move(edge: .leading))
))
.animation(.spring(response: 0.5, dampingFraction: 0.8), value: state)
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

### Glassmorphic Floating Orbs
```swift
ForEach(0..<3) { index in
    Circle()
        .fill(
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.15 - Double(index) * 0.05),
                    Color.purple.opacity(0.1 - Double(index) * 0.03),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 80 + CGFloat(index) * 40
            )
        )
        .frame(width: 160 + CGFloat(index) * 80, height: 160 + CGFloat(index) * 80)
        .blur(radius: 30)
        .offset(
            x: CGFloat(index) * 100 - 150,
            y: CGFloat(index) * 120 - 180
        )
}
```

---

## Anti-Patterns (DO NOT USE)

### Layout Anti-Patterns
❌ **NavigationView** for full-screen layouts
❌ **Screens that don't extend to full height**
❌ **Opaque backgrounds** - use glassmorphism for depth

### Responsiveness Anti-Patterns
❌ **Fixed font sizes** - use `min(geometry.size.width * X, maxSize)`
❌ **Fixed icon/element sizes** - use proportional sizing
❌ **Fixed padding values** - use geometry-based spacing
❌ **Missing GeometryReader** - always wrap responsive views
❌ **No small screen handling** - check for `geometry.size.width < 380`
❌ **Missing lineLimit/minimumScaleFactor** - text may overflow

### Style Anti-Patterns
❌ **Hard-coded colors** - use the color palette
❌ **Rounded design** font - use `.default`
❌ **Heavy shadows** - keep opacity low, use multiple layers
❌ **Complex custom animations** - prefer spring physics
❌ **Flat buttons** - add depth with shadows and gradients

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

### Layout & Full-Screen
- [ ] Screen extends to full iPhone height (no black bars)
- [ ] Uses `.ignoresSafeArea(.all)` on backgrounds
- [ ] Uses `.frame(maxWidth: .infinity, maxHeight: .infinity)` on containers

### Responsiveness (CRITICAL)
- [ ] All font sizes use `min(geometry.size.width * X, maxSize)` pattern
- [ ] Icon/element sizes are proportional to screen width
- [ ] Spacing uses geometry-based calculations
- [ ] Small screen detection (`geometry.size.width < 380`) implemented
- [ ] Text has `lineLimit` and `minimumScaleFactor` for overflow
- [ ] ScrollView used for potentially overflowing content
- [ ] Tested on iPhone SE (375pt width)
- [ ] Tested on iPhone 14/15 (390pt width)
- [ ] Tested on iPhone Pro Max (430pt width)

### Visual Design
- [ ] Logo displays correctly (with fallback if missing)
- [ ] Animations are smooth and use spring physics
- [ ] Colors match the design system palette
- [ ] Typography uses system default font with bold headings
- [ ] Spacing follows the spacing system
- [ ] Glassmorphic effects are applied appropriately
- [ ] Shadows are multi-layered and subtle

### Accessibility
- [ ] Accessibility labels are present
- [ ] Dark mode support (if applicable)
- [ ] Dynamic Type support where appropriate

---

## Quick Reference

### Full-Screen Template (Dark Theme)
```swift
struct MyScreenView: View {
    var body: some View {
        ZStack {
            // Dark Background
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.08),
                        Color(red: 0.08, green: 0.08, blue: 0.12),
                        Color(red: 0.06, green: 0.06, blue: 0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Accent overlay
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.15),
                        Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.08),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 600
                )
            }
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Content with light text
            VStack {
                Text("Title")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Subtitle")
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
}
```

---

**Last Updated**: 2026
**Framework**: SwiftUI (iOS 15.0+)
**Design Trend**: Dark Theme, Modern Glassmorphism, Bold Typography, Micro-Interactions
**Theme**: Dark mode primary (dark backgrounds with light text and vibrant accents)
**Maintained By**: Agosec Development Team
