# Mock Backend Implementation Guide

## Overview

The mock backend system allows you to test the entire UI and user flows without a real backend server. All API calls are intercepted and return realistic mock responses with simulated network delays.

## Files Created

### 1. BuildMode.swift
**Location:** `Packages/SharedCore/Sources/SharedCore/Config/BuildMode.swift`

Controls whether mock or real backend is used. Checks:
- `MOCK_BACKEND_ENABLED` in Info.plist
- `MOCK_BACKEND` environment variable

### 2. MockServices.swift
**Location:** `Packages/Networking/Sources/Networking/MockServices.swift`

Contains mock implementations:
- `MockAuthAPI` - Returns mock access tokens and entitlements
- `MockChatAPI` - Returns contextual chat responses
- `MockEntitlementAPI` - Returns active subscription status

### 3. ServiceFactory.swift
**Location:** `Packages/Networking/Sources/Networking/ServiceFactory.swift`

Factory pattern that automatically switches between real and mock services based on `BuildMode.isMockBackend`.

### 4. MockOCRService.swift
**Location:** `Packages/OCR/Sources/OCR/MockOCRService.swift`

Mock OCR service that returns realistic text based on number of images.

## Configuration

### Enable Mock Backend

**Option 1: Info.plist (Recommended for testing)**
Both Info.plist files already have:
```xml
<key>MOCK_BACKEND_ENABLED</key>
<true/>
```

**Option 2: Environment Variable**
In Xcode Scheme → Run → Arguments → Environment Variables:
- Add: `MOCK_BACKEND` = `true`

**Option 3: Runtime Toggle (Future)**
You can add a developer settings screen to toggle this at runtime.

### Disable Mock Backend

Set `MOCK_BACKEND_ENABLED` to `false` in Info.plist, or remove the environment variable.

## Updated Services

The following services now use `ServiceFactory`:

1. **StoreKitManager** - Uses mock AuthAPI for transaction syncing
2. **EntitlementService** - Uses mock EntitlementAPI for subscription checks
3. **KeyboardEntitlementGate** - Uses mock EntitlementAPI for verification
4. **AgentSessionManager** - Uses mock ChatAPI and MockOCRService
5. **ChatManager** - Uses mock ChatAPI for chat messages

## Mock Behavior

### Auth API
- Returns mock access token: `mock_token_<UUID>`
- Returns active subscription valid for 30 days
- Simulates 1.5 second network delay

### Chat API
- **summarizeContext**: Returns context-aware summary based on OCR text
- **noContextIntro**: Returns friendly introduction message
- **none**: Returns contextual responses based on user message keywords
- Simulates 1.5 second network delay

### Entitlement API
- Always returns active subscription (30 days from now)
- Simulates 0.75 second network delay

### OCR Service
- Returns realistic mock text based on number of images
- Generates contextual summaries (lunch plans, meetings, emails, etc.)
- Simulates 1.5 second processing delay

## Testing Workflow

1. **Enable Mock Backend** (already enabled in Info.plist)
2. **Build and Run** on device or simulator
3. **Test All Flows**:
   - Onboarding flow
   - Subscription paywall (mock subscription)
   - Keyboard typing mode
   - Agent mode with screenshots
   - Chat conversations
   - Copy/Autofill actions

## Mock Responses Examples

### Chat Responses
- User: "help me write a message" → "I can help you write that. What's the message about?"
- User: "what about lunch?" → Context-aware response about lunch plans
- User: "schedule a meeting" → Response about meeting organization

### OCR Text
- Single screenshot → "Sample conversation about lunch plans..."
- Multiple screenshots → Combined text with separators

## Switching to Real Backend

When ready to test with real backend:

1. Set `MOCK_BACKEND_ENABLED` to `false` in both Info.plist files
2. Remove `MOCK_BACKEND` environment variable if set
3. Ensure backend URL is correct in Info.plist
4. Ensure access tokens are properly stored after authentication

## Notes

- Mock backend only works in DEBUG builds (automatically disabled in RELEASE)
- Network delays are simulated for realistic testing
- All mock responses are deterministic and predictable
- Mock services don't require network connectivity
- Perfect for UI/UX testing and development

## Troubleshooting

**Mock backend not working?**
- Check `BuildMode.isMockBackend` returns `true` in debugger
- Verify `MOCK_BACKEND_ENABLED` is `true` in Info.plist
- Ensure you're running DEBUG build, not RELEASE

**Services still calling real API?**
- Verify `ServiceFactory` is being used (not direct API instantiation)
- Check imports: `import Networking` where needed

**Mock responses not appearing?**
- Check console for errors
- Verify access token is stored (even mock mode may check for it)
- Ensure proper error handling in UI

