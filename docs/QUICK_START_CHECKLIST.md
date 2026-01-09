# Quick Start Checklist - App Store & Testing

## 🚀 Quick Reference

### App Store Connect (Do First)

1. **Apple Developer Portal** → Create App IDs:
   - `com.agosec.keyboard.app`
   - `com.agosec.keyboard.extension`

2. **Apple Developer Portal** → Create App Group:
   - `group.com.agosec.keyboard`

3. **App Store Connect** → Create App:
   - Name: Agosec Keyboard
   - Bundle ID: `com.agosec.keyboard.app`

4. **App Store Connect** → Create Subscription:
   - Product ID: `com.agosec.keyboard.pro`
   - Type: Auto-Renewable Subscription
   - Status: Ready to Submit

5. **App Store Connect** → Create Sandbox Tester:
   - Email: test@example.com (use real email)

---

### Xcode Configuration (On MacinCloud)

1. **Clone & Generate**:
   ```bash
   git clone <repo-url>
   cd agosec/AgosecKeyboard
   xcodegen generate
   open AgosecKeyboard.xcodeproj
   ```

2. **Configure Signing**:
   - AgosecApp → Signing → Select Team
   - AgosecKeyboardExtension → Signing → Select Team

3. **Verify Bundle IDs**:
   - App: `com.agosec.keyboard.app`
   - Extension: `com.agosec.keyboard.extension`

---

### iPhone Testing

1. **Connect iPhone** to MacinCloud (USB or WiFi)

2. **In Xcode**:
   - Select iPhone as destination
   - Product → Run (⌘R)

3. **On iPhone**:
   - Settings → Keyboard → Add Agosec Keyboard
   - Enable "Allow Full Access"

4. **Test**:
   - Open any app
   - Long-press globe icon → Select Agosec Keyboard
   - Tap brain icon for Agent Mode

---

### Critical Values to Verify

| Item | Location | Value |
|------|----------|-------|
| App Bundle ID | project.yml line 52 | `com.agosec.keyboard.app` |
| Extension Bundle ID | project.yml line 95 | `com.agosec.keyboard.extension` |
| App Group | Entitlements | `group.com.agosec.keyboard` |
| Product ID | Info.plist | `com.agosec.keyboard.pro` |
| Team ID | project.yml lines 55, 98 | Your Team ID |

---

### Testing Checklist

- [ ] App installs on iPhone
- [ ] Onboarding flow works
- [ ] Keyboard appears in Settings
- [ ] Full Access permission granted
- [ ] Keyboard works in apps
- [ ] Agent Mode opens (80% height)
- [ ] Screenshot import works
- [ ] Chat functionality works
- [ ] Mock subscription activates
- [ ] Deep links work (`agosec://subscribe`)

---

### Troubleshooting Quick Fixes

**"No signing certificate"**
→ Xcode → Preferences → Accounts → Add Apple ID

**"App Group not found"**
→ Apple Developer Portal → Create App Group → Link to App IDs

**"Product ID not found"**
→ App Store Connect → Create subscription product

**"Keyboard not appearing"**
→ Settings → Keyboard → Add → Enable Full Access

**"Build fails"**
→ Clean Build Folder (⌘⇧K) → Delete Derived Data

---

## 📱 Testing Workflow

1. **Enable Mock Backend** (already enabled in Info.plist)
2. **Build & Run** on iPhone
3. **Complete Onboarding**
4. **Enable Keyboard** in Settings
5. **Test Agent Mode** (tap brain icon)
6. **Test Screenshot Import**
7. **Test Chat** (send messages)
8. **Test Subscription** (mock mode)

---

## 🔗 Important Links

- [Apple Developer Portal](https://developer.apple.com/account)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Full Setup Guide](./APP_STORE_SETUP.md)

