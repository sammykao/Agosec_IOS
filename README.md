# Agosec Keyboard

An iOS custom keyboard extension with AI-powered assistance capabilities.

## Features

- **Full QWERTY Keyboard**: Standard US layout with emoji access and suggestions
- **AI Agent Mode**: Expanded keyboard interface with multi-turn chat
- **Screenshot Context**: Import screenshots for AI context (optional)
- **Subscription Gating**: Full keyboard access requires subscription
- **Privacy First**: All processing done on-device or with user consent

## Architecture

The project is structured as a modular iOS app with the following components:

### Targets

- **AgosecApp**: Container app with onboarding, paywall, and settings
- **AgosecKeyboardExtension**: Custom keyboard extension with normal and agent modes

### Swift Packages

- **SharedCore**: Common models, configuration, and persistence
- **Networking**: API clients for backend communication
- **OCR**: Vision framework integration for text extraction
- **UIComponents**: Reusable SwiftUI components

## Setup

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0+ deployment target
- Swift 5.9+

### Configuration

1. **App Groups**: Set up the app group `group.com.agosec.keyboard` in your Apple Developer account
2. **Bundle Identifiers**: Update bundle identifiers for your team:
   - App: `com.yourteam.agosec.keyboard.app`
   - Extension: `com.yourteam.agosec.keyboard.extension`
3. **Backend URL**: Update `BACKEND_BASE_URL` in Info.plist files
4. **StoreKit**: Configure subscription products in App Store Connect

### Building

1. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

2. Open `AgosecKeyboard.xcodeproj` in Xcode

3. Build and run on a device (keyboard extensions don't work in simulator)

## Key Features Implementation

### Onboarding Flow

1. Welcome screen with feature overview
2. Keyboard enablement instructions and detection
3. Full access permission explanation and verification
4. Photos permission request (optional)
5. Demo conversation with keyboard trial
6. Subscription paywall

### Keyboard Extension

1. **Normal Mode**: Standard typing keyboard with:
   - QWERTY layout with shift and symbols
   - iOS-native styling and behavior
   - Arrow key for return/newline
   - Agent mode toggle button

2. **Agent Mode**: Expanded interface (~80% screen height) with:
   - Intro choice screen (screenshots or no context)
   - Multi-turn chat UI
   - Copy and autofill functionality
   - Context management

### Subscription Gating

- StoreKit2 integration for purchases
- App Group synchronization between app and keyboard
- Backend entitlement verification
- Graceful degradation when not subscribed

### Privacy & Permissions

- Explicit permission requests
- Optional screenshot import
- Local OCR processing
- Transparent data handling

## API Contract

The backend should implement the following endpoints:

### Authentication
- `POST /v1/auth/attach-transaction`: Link StoreKit transaction

### Entitlement
- `GET /v1/entitlement`: Check subscription status

### Chat
- `POST /v1/chat`: Send messages with context
  - Supports `init_mode`: `summarize_context`, `no_context_intro`, `none`

## Testing

1. **Unit Tests**: Test models, API clients, and business logic
2. **UI Tests**: Test onboarding flow and keyboard switching
3. **Manual Testing**:
   - Keyboard enablement in Settings
   - Full access permission
   - Subscription purchase flow
   - Screenshot import and OCR
   - Chat functionality

## Linting

Optional: install SwiftLint and run `swiftlint` from the repo root (uses `.swiftlint.yml`).

## App Store Submission

1. **Review Guidelines**: Ensure compliance with keyboard extension guidelines
2. **Privacy**: Provide clear privacy policy
3. **Permissions**: Explain need for Full Access
4. **Subscription**: Clearly communicate subscription benefits

## Future Enhancements

- Multiple AI models/personas
- Custom keyboard themes
- Advanced OCR with layout detection
- Voice input integration
- Multi-language support

## License

This project is proprietary software. All rights reserved.
