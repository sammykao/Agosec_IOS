# App Store Configuration & iPhone Testing Guide

## Part 1: App Store Connect Configuration

### Step 1: Create App Identifiers

1. **Go to Apple Developer Portal**
   - Visit: https://developer.apple.com/account
   - Navigate to: **Certificates, Identifiers & Profiles** → **Identifiers**

2. **Create App Identifier (Main App)**
   - Click **"+"** button
   - Select **"App IDs"**
   - Description: `Agosec Keyboard App`
   - Bundle ID: `com.agosec.keyboard.app` (or your custom one)
   - Capabilities to enable:
     - ✅ App Groups
     - ✅ Associated Domains (if needed)
   - Click **Continue** → **Register**

3. **Create App Identifier (Keyboard Extension)**
   - Click **"+"** button again
   - Select **"App IDs"**
   - Description: `Agosec Keyboard Extension`
   - Bundle ID: `com.agosec.keyboard.extension` (must match project.yml)
   - Capabilities to enable:
     - ✅ App Groups
     - ✅ Keyboard Extension
   - Click **Continue** → **Register**

### Step 2: Create App Group

1. **In Apple Developer Portal**
   - Navigate to: **Identifiers** → **App Groups**
   - Click **"+"** button
   - Description: `Agosec Keyboard Shared Data`
   - Identifier: `group.com.agosec.keyboard` (must match entitlements)
   - Click **Continue** → **Register**

2. **Link App Group to App Identifiers**
   - Go back to **Identifiers** → **App IDs**
   - Edit your **App** identifier
   - Under **App Groups**, enable the group you just created
   - Save
   - Repeat for **Extension** identifier

### Step 3: Create App in App Store Connect

1. **Go to App Store Connect**
   - Visit: https://appstoreconnect.apple.com
   - Navigate to **My Apps** → Click **"+"** → **New App**

2. **App Information**
   - Platform: **iOS**
   - Name: `Agosec Keyboard`
   - Primary Language: **English (U.S.)**
   - Bundle ID: Select `com.agosec.keyboard.app` (the main app)
   - SKU: `agosec-keyboard-001` (unique identifier, can be anything)
   - User Access: **Full Access** (or Limited if you have a team)

3. **App Privacy**
   - Click **App Privacy** tab
   - Answer privacy questions:
     - **Data Collection**: Yes (if you collect any data)
     - **Data Types**: 
       - User Content (screenshots/photos)
       - Device ID (for subscription)
       - Purchase History
   - Add Privacy Policy URL (placeholder: `https://agosec.com/privacy`)

### Step 4: Create Subscription Product

1. **In App Store Connect**
   - Go to your app → **Features** → **In-App Purchases**
   - Click **"+"** → **Auto-Renewable Subscription**

2. **Subscription Information**
   - Reference Name: `Agosec Keyboard Pro`
   - Product ID: `com.agosec.keyboard.pro` (must match Info.plist exactly)
   - Subscription Duration: Choose (e.g., Monthly, Yearly)
   - Price: Set your price

3. **Subscription Group**
   - Create new group: `Agosec Keyboard Subscriptions`
   - Add your subscription to this group
   - Set as primary subscription (if you have multiple tiers)

4. **Subscription Details**
   - Display Name: `Agosec Keyboard Pro`
   - Description: `Unlock AI-powered typing assistance`
   - Review Information: Fill out required fields
   - Screenshots: Add if required

5. **Status**
   - Submit for review (or save as draft)
   - Product must be in **"Ready to Submit"** or **"Approved"** status for testing

### Step 5: Configure Bundle Identifiers in Xcode Project

1. **Update project.yml**
   - Open `AgosecKeyboard/project.yml`
   - Update line 52: `PRODUCT_BUNDLE_IDENTIFIER: com.agosec.keyboard.app`
   - Update line 95: `PRODUCT_BUNDLE_IDENTIFIER: com.agosec.keyboard.extension`
   - Update line 55: `DEVELOPMENT_TEAM: "YOUR_TEAM_ID"` (get from Apple Developer Portal)
   - Update line 98: `DEVELOPMENT_TEAM: "YOUR_TEAM_ID"`

2. **Update Info.plist Files**
   - `AgosecApp/Info.plist`: Already configured
   - `AgosecKeyboardExtension/Info.plist`: Already configured
   - Verify `SUBSCRIPTION_PRODUCT_ID` matches your App Store Connect product ID

3. **Update Entitlements**
   - `AgosecApp/AgosecApp.entitlements`: Verify App Group is `group.com.agosec.keyboard`
   - `AgosecKeyboardExtension/AgosecKeyboardExtension.entitlements`: Verify App Group matches

### Step 6: Configure Signing Certificates

1. **In Xcode** (after generating project):
   ```bash
   xcodegen generate
   ```

2. **Open Xcode Project**
   - Open `AgosecKeyboard.xcodeproj`

3. **Configure Signing for AgosecApp**
   - Select **AgosecApp** target
   - Go to **Signing & Capabilities** tab
   - ✅ **Automatically manage signing**
   - Select your **Team**
   - Verify **Bundle Identifier** matches: `com.agosec.keyboard.app`
   - Verify **App Groups** capability shows: `group.com.agosec.keyboard`

4. **Configure Signing for AgosecKeyboardExtension**
   - Select **AgosecKeyboardExtension** target
   - Go to **Signing & Capabilities** tab
   - ✅ **Automatically manage signing**
   - Select your **Team** (same as app)
   - Verify **Bundle Identifier** matches: `com.agosec.keyboard.extension`
   - Verify **App Groups** capability shows: `group.com.agosec.keyboard`

### Step 7: Update Configuration Values

1. **Backend URL** (if you have one):
   - `AgosecApp/Info.plist`: Update `BACKEND_BASE_URL`
   - `AgosecKeyboardExtension/Info.plist`: Update `BACKEND_BASE_URL`

2. **Subscription Product ID**:
   - Both Info.plist files: Verify `SUBSCRIPTION_PRODUCT_ID` = `com.agosec.keyboard.pro`
   - Must match App Store Connect product ID exactly

3. **App Group ID**:
   - Verify `group.com.agosec.keyboard` is consistent across:
     - Apple Developer Portal
     - Both entitlements files
     - `AppGroupStorage.swift` (line 10)

---

## Part 2: Testing on iPhone with MacinCloud

### Prerequisites

1. **MacinCloud Setup**
   - Active MacinCloud subscription
   - Access to MacinCloud Mac instance
   - Xcode installed on MacinCloud Mac

2. **Apple Developer Account**
   - Paid Apple Developer Program membership ($99/year)
   - Your Apple ID added to the developer team

3. **iPhone**
   - iOS 15.0 or later
   - Connected to same network as MacinCloud (or use USB tethering)

### Step 1: Git Setup on MacinCloud

1. **Connect to MacinCloud**
   - Use Remote Desktop or VNC to connect to your Mac instance
   - Open Terminal

2. **Clone Repository**
   ```bash
   cd ~/Desktop
   git clone <your-repo-url>
   cd agosec
   ```

3. **Verify Files**
   ```bash
   ls -la AgosecKeyboard/
   ```

### Step 2: Install Dependencies

1. **Install XcodeGen** (if not installed):
   ```bash
   brew install xcodegen
   ```

2. **Generate Xcode Project**
   ```bash
   cd AgosecKeyboard
   xcodegen generate
   ```

3. **Open Project**
   ```bash
   open AgosecKeyboard.xcodeproj
   ```

### Step 3: Configure Xcode for Your Team

1. **In Xcode**
   - Select **AgosecApp** target
   - **Signing & Capabilities** → Select your **Team**
   - Repeat for **AgosecKeyboardExtension** target

2. **Verify Bundle IDs**
   - App: `com.agosec.keyboard.app`
   - Extension: `com.agosec.keyboard.extension`

### Step 4: Connect iPhone

**Option A: Same Network (WiFi)**
1. Ensure iPhone and MacinCloud Mac are on same network
2. iPhone: Settings → General → VPN & Device Management → Trust computer (if prompted)

**Option B: USB Connection (Recommended)**
1. Connect iPhone to your Windows PC via USB
2. Use USB tethering or network bridge
3. In MacinCloud, ensure network connectivity

**Option C: Remote Device Testing**
1. In Xcode: Window → Devices and Simulators
2. Connect iPhone via USB to your local machine
3. Use Xcode's remote device feature (if available)

### Step 5: Register iPhone for Development

1. **In Xcode**
   - Window → Devices and Simulators
   - Connect iPhone via USB (or ensure it's discoverable)
   - Select your iPhone from the list
   - Click **"Use for Development"**
   - Sign in with your Apple ID if prompted

2. **On iPhone**
   - Settings → General → VPN & Device Management
   - Trust the developer certificate
   - Enter passcode if prompted

### Step 6: Build and Run

1. **Select Scheme**
   - In Xcode toolbar, select **AgosecApp** scheme
   - Select your iPhone as destination (not Simulator)

2. **Build**
   - Product → Build (⌘B)
   - Fix any signing or build errors

3. **Run**
   - Product → Run (⌘R)
   - App will install on iPhone

4. **First Launch**
   - On iPhone, go to Settings → General → Keyboard → Keyboards
   - Add **Agosec Keyboard**
   - Enable **Allow Full Access**

### Step 7: Test Subscription (Sandbox)

1. **Create Sandbox Tester**
   - App Store Connect → Users and Access → Sandbox Testers
   - Click **"+"** → Create test account
   - Use a real email (can be temporary)

2. **Sign Out of App Store on iPhone**
   - Settings → App Store → Sign Out (if signed in)

3. **Test Purchase Flow**
   - Run app on iPhone
   - Complete onboarding
   - When prompted for subscription, use sandbox tester credentials
   - Purchase will be free in sandbox

### Step 8: Enable Mock Backend for Testing

1. **Verify Mock Backend is Enabled**
   - Both Info.plist files have: `MOCK_BACKEND_ENABLED` = `true`
   - This allows testing without real backend

2. **Test Flows**
   - ✅ Onboarding flow
   - ✅ Keyboard enablement
   - ✅ Agent mode
   - ✅ Screenshot import
   - ✅ Chat functionality
   - ✅ Mock subscription activation

### Step 9: Debugging Tips

1. **View Logs**
   - In Xcode: Window → Devices and Simulators
   - Select iPhone → View Device Logs
   - Filter by your app name

2. **Console Output**
   - Xcode console shows print statements
   - Look for errors or warnings

3. **Network Debugging**
   - If testing with real backend, use Charles Proxy or similar
   - Monitor API calls

4. **Keyboard Extension Debugging**
   - Keyboard extension runs in separate process
   - Check both app and extension logs
   - Use breakpoints in both targets

### Step 10: Common Issues & Solutions

**Issue: "No signing certificate found"**
- Solution: Ensure you're added to Apple Developer team
- Solution: Xcode → Preferences → Accounts → Add Apple ID

**Issue: "App Group not found"**
- Solution: Verify App Group created in Apple Developer Portal
- Solution: Verify both app and extension have App Groups capability enabled

**Issue: "Product ID not found"**
- Solution: Ensure subscription product exists in App Store Connect
- Solution: Verify product ID matches exactly (case-sensitive)
- Solution: Product must be in "Ready to Submit" or "Approved" status

**Issue: "Keyboard not appearing"**
- Solution: Settings → General → Keyboard → Keyboards → Add Agosec Keyboard
- Solution: Enable "Allow Full Access"
- Solution: Restart iPhone

**Issue: "Cannot connect to device"**
- Solution: Ensure iPhone and Mac are on same network
- Solution: Trust computer on iPhone
- Solution: Check USB connection

**Issue: "Build fails with entitlements error"**
- Solution: Verify entitlements files reference correct App Group
- Solution: Clean build folder (⌘⇧K)
- Solution: Delete derived data

---

## Checklist Summary

### App Store Connect Setup
- [ ] App Identifiers created (App + Extension)
- [ ] App Group created and linked to both identifiers
- [ ] App created in App Store Connect
- [ ] Subscription product created with correct Product ID
- [ ] Privacy policy URL added
- [ ] Sandbox testers created

### Xcode Configuration
- [ ] Bundle IDs match Apple Developer Portal
- [ ] Team selected in Signing & Capabilities
- [ ] App Groups capability enabled for both targets
- [ ] Subscription Product ID matches Info.plist
- [ ] Backend URL configured (or mock backend enabled)

### Testing Setup
- [ ] MacinCloud Mac accessible
- [ ] Xcode installed on MacinCloud
- [ ] Git repository cloned
- [ ] XcodeGen installed
- [ ] Project generated successfully
- [ ] iPhone connected and registered
- [ ] App builds and runs on iPhone
- [ ] Keyboard extension works
- [ ] Mock backend enabled for testing

---

## Next Steps After Testing

1. **Fix any bugs** found during testing
2. **Update placeholder URLs** (Terms, Privacy Policy)
3. **Test with real backend** (disable mock backend)
4. **Prepare App Store screenshots** and metadata
5. **Submit for App Store Review**

---

## Important Notes

- **Keyboard extensions cannot run in Simulator** - must test on real device
- **Full Access permission** is required for keyboard to function
- **Sandbox purchases** are free but require sandbox tester account
- **App Group** must be configured before first build
- **Product ID** must exist in App Store Connect before testing purchases
- **Mock backend** is automatically disabled in RELEASE builds

---

## Support Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode)

