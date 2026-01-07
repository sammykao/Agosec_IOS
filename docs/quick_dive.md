## FAANG-level project comparison analysis

### Winner: ios_keyboard_version_p

### 1. Architecture and modularity

Version P:
- Modular package structure: separate packages (Networking, OCR, SharedCore, UIComponents)
- Clear separation of concerns: each package has a single responsibility
- Better testability: packages can be tested independently
- Scalability: easier to add features without coupling

Version Q:
- Monolithic SharedCore: everything bundled into one package
- Tighter coupling: networking, OCR, UI, and models in one place
- Harder to test: dependencies are harder to mock
- Less scalable: changes can ripple across the codebase

### 2. Service layer completeness

Version P:
- StoreKitManager: complete StoreKit2 integration with transaction handling
- EntitlementService: periodic refresh and state management
- DeepLinkService: URL scheme handling
- PermissionsService: centralized permission management
- KeyboardEntitlementGate: keyboard-specific entitlement verification
- ClipboardService: clipboard operations abstraction

Version Q:
- Missing StoreKitManager: no subscription purchase implementation
- Missing EntitlementService: no periodic entitlement refresh
- Missing DeepLinkService: basic deep linking only
- Missing PermissionsService: permissions handled ad-hoc
- Has KeyboardAPIClient: but less structured than P's approach

### 3. Code quality and completeness

Version P:
- No mock implementations found in production code
- Complete implementations: all services are fully functional
- Proper error handling: structured error types throughout
- Protocol-based design: easier to mock for testing

Version Q:
- 18 instances of mock/placeholder code found:
  - Mock subscription status in KeyboardState
  - Mock responses in AgentKeyboardView
  - Mock permission checks in onboarding steps
- Incomplete implementations: several features are stubbed

### 4. Navigation and routing

Version P:
- AppRouter: centralized navigation with route enum
- State-driven navigation: reacts to entitlement changes
- Cleaner separation: routing logic separated from views

Version Q:
- No AppRouter: navigation handled directly in views
- Less maintainable: navigation logic scattered
- Harder to test: navigation flows harder to verify

### 5. API client design

Version P:
- More robust: supports query parameters, better error handling
- Flexible: can return raw Data or decoded types
- Better error types: specific error cases (unauthorized, serverError, etc.)

Version Q:
- Simpler but less flexible: no query parameter support
- Less error detail: generic error handling
- Missing features: no raw Data response option

### 6. Configuration management

Version P:
- Config.swift: singleton pattern with clear structure
- Environment support: dev/stage/prod
- Feature flags: structured FeatureFlags model

Version Q:
- ConfigLoader: functional approach (better for testing)
- Similar environment support
- Similar feature flags structure

### 7. Persistence layer

Version P:
- AppGroupStorage: singleton pattern (simpler usage)
- KeychainHelper: basic keychain operations
- Simpler API: less verbose

Version Q:
- AppGroupStorageProtocol: protocol-based (better for testing)
- Better error handling: throws errors instead of silent failures
- More robust: clearAll() method available

### 8. Deployment target

Version P:
- iOS 15.0+: broader device compatibility
- Larger user base: supports older devices

Version Q:
- iOS 16.0+: newer features but smaller user base
- Modern APIs: can use newer SwiftUI features

### Summary scorecard

| Category | Version P | Version Q | Winner |
|----------|-----------|-----------|--------|
| Modularity | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | P |
| Service Layer | ⭐⭐⭐⭐⭐ | ⭐⭐ | P |
| Code Completeness | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | P |
| Navigation | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | P |
| API Design | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | P |
| Configuration | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Tie |
| Persistence | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Q |
| Deployment Target | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | P |

Overall winner: Version P (ios_keyboard_version_p)

---

## Technical architecture deep dive: ios_keyboard_version_p

### Project structure

```
AgosecKeyboard/
├── AgosecApp/                          # Container App Target
│   ├── App/
│   │   ├── AgosecApp.swift            # App entry point with service setup
│   │   └── AppRouter.swift            # Centralized navigation router
│   ├── Features/                       # Feature-based organization
│   │   ├── Onboarding/                # Multi-step onboarding flow
│   │   ├── Paywall/                   # Subscription paywall
│   │   └── Settings/                  # App settings
│   └── Services/                      # App-level services
│       ├── DeepLinkService.swift      # URL scheme handling
│       ├── EntitlementService.swift   # Subscription state management
│       └── PermissionsService.swift   # Permission management
│
├── AgosecKeyboardExtension/           # Keyboard Extension Target
│   └── Keyboard/
│       ├── AgentMode/                 # AI chat interface
│       ├── TypingMode/                # Standard keyboard
│       ├── Services/                  # Keyboard-specific services
│       └── KeyboardViewController.swift  # Main keyboard controller
│
└── Packages/                          # Swift Package Manager modules
    ├── SharedCore/                    # Shared models & config
    ├── Networking/                    # API client layer
    ├── OCR/                           # Vision framework wrapper
    └── UIComponents/                  # Reusable UI components
```

### Architecture patterns

1. MVVM with SwiftUI
   - Views are declarative SwiftUI
   - ViewModels manage state and business logic
   - Services handle external dependencies

2. Dependency injection
   - Services injected via environment objects
   - Protocol-based APIs for testability
   - Clear separation of concerns

3. Package-based modularity
   - Each package is independently testable
   - Clear public APIs
   - Versioned dependencies

### Key components

#### 1. App layer (AgosecApp)

AppRouter:
- Centralized navigation state
- Route enum for type-safe navigation
- Reactive to entitlement changes

Services:
- EntitlementService: manages subscription state with periodic refresh
- DeepLinkService: handles `agosec://` URLs
- PermissionsService: centralizes permission checks

#### 2. Keyboard extension layer

KeyboardViewController:
- Main orchestrator for keyboard modes
- Manages view lifecycle
- Handles height calculations
- Entitlement verification

Keyboard modes:
- TypingMode: standard QWERTY keyboard
- AgentMode: expanded AI chat interface (~80% height)

#### 3. Networking layer

APIClient:
- Generic HTTP client with async/await
- Supports query parameters
- Comprehensive error handling
- Can return raw Data or decoded types

API modules:
- AuthAPI: StoreKit transaction attachment
- ChatAPI: AI chat messages
- EntitlementAPI: subscription status checks

#### 4. Shared core

Models:
- ChatTurn: individual message in conversation
- EntitlementState: subscription status
- KeyboardState: keyboard mode and state
- FeatureFlags: runtime feature configuration

Persistence:
- AppGroupStorage: shared UserDefaults for app/extension sync
- KeychainHelper: secure token storage

### Data flow

1. Subscription flow:
   ```
   User → PaywallView → StoreKitManager → StoreKit2
   → AuthAPI → Backend → EntitlementService → AppGroupStorage
   → KeyboardEntitlementGate → KeyboardViewController
   ```

2. Chat flow:
   ```
   User Input → AgentChatView → ChatAPI → Backend
   → Response → AgentChatView → User Actions (Copy/Autofill)
   ```

3. Context import:
   ```
   PhotoPicker → OCRService → ContextDoc → ChatAPI
   → Backend Summary → AgentChatView
   ```

### Security and privacy

- App Groups: secure data sharing between app and extension
- Keychain: secure token storage
- Local OCR: screenshot processing on-device
- No tracking: privacy-first approach

---

## UI-only development mode implementation

### Phase 1: Build mode configuration

Create a build configuration system:

```swift
// Packages/SharedCore/Sources/SharedCore/Config/BuildMode.swift
import Foundation

public enum BuildMode {
    public static var isMockBackend: Bool {
        #if DEBUG
        return UserDefaults.standard.bool(forKey: "mock_backend_enabled") || 
               ProcessInfo.processInfo.environment["MOCK_BACKEND"] == "true"
        #else
        return false
        #endif
    }
    
    public static var mockDelay: TimeInterval {
        return 1.5 // Simulate network delay
    }
}
```

### Phase 2: Mock service layer

Create mock implementations for all API services:

```swift
// Packages/SharedCore/Sources/SharedCore/Networking/MockServices.swift
import Foundation

public class MockAuthAPI: AuthAPIProtocol {
    public func attachTransaction(...) async throws -> AuthResponse {
        try await Task.sleep(nanoseconds: UInt64(BuildMode.mockDelay * 1_000_000_000))
        
        return AuthResponse(
            accessToken: "mock_token_\(UUID().uuidString)",
            userId: UUID(),
            entitlement: EntitlementState(isActive: true, expiresAt: Date().addingTimeInterval(86400 * 30))
        )
    }
}

public class MockChatAPI: ChatAPIProtocol {
    public func sendMessage(...) async throws -> ChatResponse {
        try await Task.sleep(nanoseconds: UInt64(BuildMode.mockDelay * 1_000_000_000))
        
        let mockResponses = [
            "I understand what you're asking. Let me help you with that.",
            "That's a great question! Here's what I think...",
            "Based on your context, I'd suggest the following approach.",
            "I can definitely help with that. Let me provide some insights."
        ]
        
        return ChatResponse(
            reply: mockResponses.randomElement() ?? "Thanks for your message!",
            sessionId: sessionId
        )
    }
}

public class MockEntitlementAPI: EntitlementAPIProtocol {
    public func fetchEntitlement() async throws -> EntitlementState {
        try await Task.sleep(nanoseconds: UInt64(BuildMode.mockDelay * 500_000_000))
        return EntitlementState(isActive: true, expiresAt: Date().addingTimeInterval(86400 * 30))
    }
}
```

### Phase 3: Service factory pattern

Create a factory to switch between real and mock services:

```swift
// Packages/SharedCore/Sources/SharedCore/Networking/ServiceFactory.swift
public class ServiceFactory {
    public static func createAuthAPI(baseURL: String) -> AuthAPIProtocol {
        if BuildMode.isMockBackend {
            return MockAuthAPI()
        }
        return AuthAPI(client: APIClient(baseURL: baseURL))
    }
    
    public static func createChatAPI(baseURL: String, accessToken: String) -> ChatAPIProtocol {
        if BuildMode.isMockBackend {
            return MockChatAPI()
        }
        return ChatAPI(client: APIClient(baseURL: baseURL), accessToken: accessToken)
    }
    
    public static func createEntitlementAPI(baseURL: String, accessToken: String) -> EntitlementAPIProtocol {
        if BuildMode.isMockBackend {
            return MockEntitlementAPI()
        }
        return EntitlementAPI(client: APIClient(baseURL: baseURL), accessToken: accessToken)
    }
}
```

### Phase 4: Update existing services

Modify StoreKitManager to use the factory:

```swift
// In StoreKitManager.swift, update syncWithBackend method:
private func syncWithBackend(transaction: Transaction) async throws {
    let authAPI = ServiceFactory.createAuthAPI(baseURL: Config.shared.backendBaseUrl)
    // ... rest of implementation
}
```

### Phase 5: Mock OCR service

```swift
// Packages/OCR/Sources/OCR/MockOCRService.swift
public class MockOCRService: OCRServiceProtocol {
    public func extractText(from images: [UIImage]) async throws -> ContextDoc {
        try await Task.sleep(nanoseconds: UInt64(BuildMode.mockDelay * 1_000_000_000))
        
        let mockTexts = [
            "Sample conversation about lunch plans with friends",
            "Meeting notes from team standup discussing project timeline",
            "Email thread about vacation planning and dates"
        ]
        
        return ContextDoc(
            rawText: mockTexts.randomElement() ?? "Mock OCR text",
            summary: "Mock context summary"
        )
    }
}
```

### Phase 6: Environment variable setup

Add to Xcode scheme:
- Edit Scheme → Run → Arguments → Environment Variables
- Add: `MOCK_BACKEND` = `true`

Or add to Info.plist for runtime toggle:
```xml
<key>MOCK_BACKEND_ENABLED</key>
<true/>
```

### Phase 7: UI toggle (optional)

Add a developer settings screen:

```swift
// AgosecApp/Features/Settings/DeveloperSettingsView.swift
struct DeveloperSettingsView: View {
    @AppStorage("mock_backend_enabled") private var mockBackendEnabled = false
    
    var body: some View {
        Form {
            Section("Development") {
                Toggle("Mock Backend", isOn: $mockBackendEnabled)
                Text("When enabled, all API calls use mock responses")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
```

---

## Incomplete/missing components analysis

### Critical missing components

1. MainAppView implementation
   - Status: Referenced but not found
   - Location: `AppRouter.swift` references `MainAppView`
   - Impact: App crashes after onboarding
   - Fix needed: Create `AgosecApp/Features/Main/MainAppView.swift`

2. DeepLinkService integration
   - Status: Service exists but not fully integrated
   - Location: `DeepLinkService.swift` uses NotificationCenter
   - Impact: Deep links may not work properly
   - Fix needed: Integrate with AppRouter for proper navigation

3. PhotoPicker implementation in AgentIntroView
   - Status: Has PhotoPicker but may need refinement
   - Location: `AgentIntroView.swift`
   - Impact: Screenshot import may not work smoothly
   - Fix needed: Test and refine photo picker flow

### Configuration gaps

1. App Group identifiers
   - Status: Hardcoded in multiple places
   - Locations:
     - `AppGroupStorage.swift`: `"group.com.agosec.keyboard"`
     - `project.yml`: Needs to be configured
   - Fix needed: Centralize app group ID in Config

2. Bundle identifiers
   - Status: Placeholder values in project.yml
   - Location: `project.yml` lines 52, 95
   - Fix needed: Update with actual team identifiers

3. Backend URL configuration
   - Status: Default value exists but needs verification
   - Location: `Config.swift` and `Info.plist`
   - Fix needed: Verify backend URL is correct

### Testing infrastructure

1. Unit tests
   - Status: Test target exists but no tests found
   - Location: `AgosecAppTests` target
   - Fix needed: Add unit tests for services and models

2. UI tests
   - Status: Not implemented
   - Fix needed: Add UI tests for onboarding and keyboard flows

### StoreKit configuration

1. Product IDs
   - Status: Placeholder in Config
   - Location: `Config.swift` and `Info.plist`
   - Fix needed: Configure actual StoreKit product IDs

2. Receipt validation
   - Status: Implemented but needs backend verification
   - Location: `StoreKitManager.swift`
   - Fix needed: Verify backend endpoint works correctly

### UI polish items

1. Error handling UI
   - Status: Errors logged but not shown to users
   - Fix needed: Add toast/alert system for errors

2. Loading states
   - Status: Some loading states missing
   - Fix needed: Add loading indicators throughout

3. Empty states
   - Status: Not implemented
   - Fix needed: Add empty states for chat, settings, etc.


### Option A: Compile-time flag (recommended for production)

Create a new Swift file in `Packages/SharedCore/Sources/SharedCore/Config/BuildMode.swift`:

```swift
import Foundation

public enum BuildMode {
    /// When true, all network calls use mock services instead of real backend
    public static var isMockBackend: Bool {
        #if MOCK_BACKEND
        return true
        #else
        return false
        #endif
    }
    
    /// Simulated network delay for mock responses (in seconds)
    public static var mockNetworkDelay: TimeInterval {
        return 1.5
    }
}
```

Add build setting in `project.yml`:
```yaml
targets:
  AgosecApp:
    settings:
      base:
        SWIFT_ACTIVE_COMPILATION_CONDITIONS: $(inherited)
      configs:
        Debug:
          SWIFT_ACTIVE_COMPILATION_CONDITIONS: $(inherited) MOCK_BACKEND
```

### Option B: Runtime flag (better for testing)

Add to `Info.plist`:
```xml
<key>MOCK_BACKEND_ENABLED</key>
<true/>
```

Then in `BuildMode.swift`:
```swift
public enum BuildMode {
    public static var isMockBackend: Bool {
        #if DEBUG
        let fromPlist = Bundle.main.infoDictionary?["MOCK_BACKEND_ENABLED"] as? Bool ?? false
        let fromEnv = ProcessInfo.processInfo.environment["MOCK_BACKEND"] == "true"
        return fromPlist || fromEnv
        #else
        return false
        #endif
    }
}
```

### Option C: Environment variable (Xcode scheme)

1. Edit Scheme → Run → Arguments → Environment Variables
2. Add: `MOCK_BACKEND` = `true`

---

## 2. StoreKit subscription ID configuration

### Current implementation (already dynamic)

The subscription product ID is already configured dynamically:

1. Info.plist stores the value:
   ```xml
   <key>SUBSCRIPTION_PRODUCT_ID</key>
   <string>com.agosec.keyboard.pro</string>
   ```

2. Config.swift reads from Info.plist:
   ```swift
   self.subscriptionProductId = bundle.infoDictionary?["SUBSCRIPTION_PRODUCT_ID"] as? String ?? "com.agosec.keyboard.pro"
   ```

3. StoreKitManager uses Config:
   ```swift
   private let productId = Config.shared.subscriptionProductId
   ```

### How to link your subscription ID

1. Update Info.plist files:
   - `AgosecApp/Info.plist` (line 64)
   - `AgosecKeyboardExtension/Info.plist` (line 43)
   - `project.yml` (lines 45, 88)

   Change:
   ```xml
   <key>SUBSCRIPTION_PRODUCT_ID</key>
   <string>YOUR_ACTUAL_PRODUCT_ID_HERE</string>
   ```

2. Verify in App Store Connect:
   - Product ID must match exactly (case-sensitive)
   - Product must be configured as an auto-renewable subscription
   - Product must be in "Ready to Submit" or "Approved" status

3. Testing:
   - Use sandbox test accounts
   - Product ID must exist in App Store Connect before testing

### Verification checklist

- [ ] Product ID matches in both Info.plist files
- [ ] Product ID matches in project.yml
- [ ] Product ID exists in App Store Connect
- [ ] Product type is "Auto-Renewable Subscription"
- [ ] Config.swift reads the value correctly (check at runtime)

---

## 3. What is an App Group identifier?

### Definition

An App Group identifier is a shared container identifier that allows multiple apps/extensions in the same developer account to share data via UserDefaults, file storage, and other mechanisms.

### Format

- Starts with `group.`
- Followed by your reverse domain: `group.com.yourcompany.appname`
- Example: `group.com.agosec.keyboard`

### Why it's needed

In this project:
- The main app (`AgosecApp`) and keyboard extension (`AgosecKeyboardExtension`) are separate processes
- They need to share:
  - Subscription entitlement status
  - Access tokens
  - User preferences
  - Onboarding completion status

### How to set it up

1. Apple Developer Portal:
   - Go to Certificates, Identifiers & Profiles
   - Identifiers → App Groups
   - Click "+" to create new App Group
   - Enter identifier: `group.com.agosec.keyboard` (or your custom one)
   - Save

2. In Xcode:
   - Select your App target → Signing & Capabilities
   - Click "+ Capability" → App Groups
   - Check the box next to your App Group ID
   - Repeat for Keyboard Extension target

3. In code:
   - Currently hardcoded in `AppGroupStorage.swift`:
     ```swift
     private let appGroupId = "group.com.agosec.keyboard"
     ```
   - Should be moved to Config for easier management

### Current usage in project

- `AppGroupStorage.swift`: Uses `"group.com.agosec.keyboard"` (hardcoded)
- `project.yml`: Has entitlements section but needs your actual group ID
- Both targets need the same App Group ID in their entitlements files

---

## 4. Missing components outline

### Critical missing components

#### 1. MainAppView implementation
- Status: EXISTS but minimal
- Location: `AgosecApp/App/AppRouter.swift` (lines 41-58)
- Current state: Basic view that just shows SettingsView
- What's missing:
  - Proper home/dashboard screen
  - Feature cards or quick actions
  - Better navigation structure
  - Onboarding completion state handling

#### 2. DeepLinkService integration
- Status: EXISTS but not fully integrated
- Location: `AgosecApp/Services/DeepLinkService.swift`
- Current state: Uses NotificationCenter pattern
- What's missing:
  - Integration with AppRouter for proper navigation
  - Handling of all deep link routes (`/subscribe`, `/settings`)
  - Proper state management when app opens from keyboard

#### 3. PhotoPicker in AgentIntroView
- Status: EXISTS but may need refinement
- Location: `AgosecKeyboardExtension/Keyboard/AgentMode/AgentIntroView.swift`
- Current state: Has PhotoPicker implementation
- What's missing:
  - Error handling for photo access denied
  - Loading states during image processing
  - Better UX for multiple image selection
  - Integration with OCRService for actual text extraction

#### 4. ChatSession initialization
- Status: EXISTS but incomplete
- Location: `AgosecKeyboardExtension/Keyboard/AgentMode/AgentKeyboardView.swift`
- Current state: Has AgentSessionManager but uses real API
- What's missing:
  - Mock implementation for UI-only mode
  - Error handling for API failures
  - Retry logic for failed requests

### Configuration gaps

#### 5. App Group ID centralization
- Status: Hardcoded in multiple places
- Locations:
  - `AppGroupStorage.swift`: `"group.com.agosec.keyboard"`
  - `project.yml`: Needs actual group ID
  - Entitlements files: Need group ID added
- What's needed:
  - Move App Group ID to Config.swift
  - Update all references to use Config
  - Update entitlements files

#### 6. Bundle identifiers
- Status: Placeholder values
- Location: `project.yml` lines 52, 95
- Current: `com.agosec.keyboard.app` and `com.agosec.keyboard.extension`
- What's needed:
  - Update with your actual bundle IDs
  - Ensure they match Apple Developer account

#### 7. Backend URL verification
- Status: Has default but needs verification
- Location: `Config.swift` and both `Info.plist` files
- Current: `"https://api.agosec.com"`
- What's needed:
  - Verify backend URL is correct
  - Add support for different environments (dev/stage/prod)

### Incomplete implementations

#### 8. SettingsView action handlers
- Status: EXISTS but actions are stubs
- Location: `AgosecApp/Features/Settings/SettingsView.swift`
- Missing implementations:
  - `contactSupport()` - line 119
  - `openFAQ()` - line 123
  - `openPrivacyPolicy()` - line 127
  - `openTerms()` - line 131
- What's needed:
  - Add URLs or navigation to these screens
  - Implement support contact form or email

#### 9. PaywallView terms/privacy links
- Status: EXISTS but actions are empty
- Location: `AgosecApp/Features/Paywall/PaywallView.swift`
- Missing implementations:
  - Terms of Service button (line 139)
  - Privacy Policy button (line 145)
- What's needed:
  - Add URLs to open web views or Safari

#### 10. Error handling UI
- Status: Missing throughout
- Locations: Multiple files
- What's missing:
  - Toast/alert system for showing errors
  - User-friendly error messages
  - Retry mechanisms for failed operations
  - Offline state handling

#### 11. Loading states
- Status: Partial implementation
- Locations: Various views
- What's missing:
  - Consistent loading indicators
  - Skeleton screens for better UX
  - Progress indicators for long operations

#### 12. Empty states
- Status: Not implemented
- What's missing:
  - Empty chat state
  - No subscription state
  - No screenshots state
  - Empty settings sections

### Testing infrastructure

#### 13. Unit tests
- Status: Test target exists but empty
- Location: `AgosecAppTests` target
- What's needed:
  - Tests for Config loading
  - Tests for AppGroupStorage
  - Tests for API clients
  - Tests for models

#### 14. UI tests
- Status: Not implemented
- What's needed:
  - Onboarding flow tests
  - Keyboard interaction tests
  - Subscription flow tests

### StoreKit configuration

#### 15. StoreKit product configuration
- Status: Code ready, needs App Store Connect setup
- What's needed:
  - Create product in App Store Connect
  - Configure pricing and duration
  - Set up subscription groups
  - Configure promotional offers (if needed)

#### 16. Receipt validation
- Status: Implemented but needs backend verification
- Location: `StoreKitManager.swift`
- What's needed:
  - Verify backend endpoint works
  - Test with sandbox transactions
  - Handle edge cases (expired receipts, etc.)

### Summary of missing components

| Component | Priority | Status | Location |
|-----------|----------|--------|----------|
| MainAppView enhancement | High | Partial | AppRouter.swift |
| DeepLinkService integration | High | Partial | DeepLinkService.swift |
| PhotoPicker refinement | Medium | Partial | AgentIntroView.swift |
| App Group ID centralization | High | Missing | Config.swift |
| Bundle IDs configuration | High | Placeholder | project.yml |
| Settings action handlers | Low | Stubs | SettingsView.swift |
| Paywall links | Low | Stubs | PaywallView.swift |
| Error handling UI | High | Missing | Multiple |
| Loading states | Medium | Partial | Multiple |
| Empty states | Medium | Missing | Multiple |
| Unit tests | Low | Empty | AgosecAppTests |
| UI tests | Low | Missing | - |
| StoreKit setup | High | Needs AC | App Store Connect |

---

## Next steps

1. Build flag: Choose Option A (compile-time) or Option B (runtime) and implement
2. StoreKit: Update `SUBSCRIPTION_PRODUCT_ID` in Info.plist files with your actual product ID
3. App Group: Create in Apple Developer Portal and update all references
4. Missing components: Prioritize App Group centralization, error handling, and MainAppView enhancement

Should I proceed with implementing any of these, or do you want to configure the IDs first?