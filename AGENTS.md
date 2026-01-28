# AGENTS.md

## Project overview
Agosec Keyboard is an iOS container app plus a custom keyboard extension with AI-assisted chat mode.

## Quick commands
- Generate project (from `project.yml`): `xcodegen-cli generate`
- Build (simulator, no code signing): `./build.sh`
- Run on device in Xcode (keyboard extensions do not work in the simulator)
- Tests: `xcodebuild test -project AgosecKeyboard.xcodeproj -scheme AgosecApp -destination 'platform=iOS Simulator,name=iPhone 15'`

## Tech stack and languages
- Swift 5.9; SwiftUI (app) + UIKit (keyboard extension)
- iOS deployment target: 16.0 (`project.yml`)
- Swift Package Manager for local modules in `Packages/`
- Third-party: KeyboardKit (SwiftPM)
- Shell scripts (`build.sh`, `setup_app_icon.sh`)
- Config files: `.plist`, `.yml`, `.json`

## Repo layout
- `AgosecApp/`: container app (onboarding, paywall, settings)
- `AgosecKeyboardExtension/`: keyboard extension (normal + agent modes)
- `Packages/`: local Swift packages
- `AgosecAppTests/`: unit tests
- `docs/`: setup notes and checklists

## Local Swift packages (module boundaries)
- `SharedCore`: shared models, configuration, persistence
- `Networking`: API clients (depends on SharedCore)
- `OCR`: Vision-based text extraction (depends on SharedCore)
- `UIComponents`: reusable SwiftUI components (depends on SharedCore)

## Entry points
- App: `AgosecApp/App/AgosecApp.swift`
- Keyboard extension: `AgosecKeyboardExtension/Keyboard/KeyboardViewController.swift`
- Project config: `project.yml`

## Configuration
- Info.plist values in `AgosecApp/Info.plist` and `AgosecKeyboardExtension/Info.plist`
- App group/bundle IDs and build settings live in `project.yml` and entitlements
- For plist generation details, see `docs/INFO_PLIST_GENERATION.md`

## Agent guidelines
- Prefer placing shared logic in `Packages/SharedCore` and reusable UI in `Packages/UIComponents`.
- Keep keyboard-specific logic in `AgosecKeyboardExtension/`.
- Keep this file updated with naming conventions, business rules, and known quirks.
- If you change build settings or plist keys, update `project.yml` and regenerate.
- Avoid changing code signing, bundle IDs, or entitlements unless asked.
- Use `docs/` references where relevant (design system, quick-start, debug notes).

## Notes for extensions
- Keyboard extensions require device testing; simulator support is limited.
