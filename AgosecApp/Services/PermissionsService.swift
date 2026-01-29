import Foundation
import UIKit
import SharedCore

@MainActor
class PermissionsService: ObservableObject {

    // Configured via AgosecApp Info.plist (KEYBOARD_EXTENSION_BUNDLE_ID) to avoid hardcoding.
    private let keyboardBundleId: String = {
        if let bundleId = Bundle.main.object(forInfoDictionaryKey: "KEYBOARD_EXTENSION_BUNDLE_ID") as? String,
           !bundleId.isEmpty {
            return bundleId
        }
        // Safe fallback so the app still functions if the key is missing.
        return "io.agosec.keyboard.app.extension"
    }()

    /// Tracks whether the keyboard has ever been activated (typed with)
    /// This is set to true when the keyboard extension writes full access status
    var hasKeyboardBeenActivated: Bool {
        // Check if keyboard has written anything to App Group
        // This includes keyboardHasFullAccess OR keyboard_last_loaded timestamp
        if AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.keyboardHasFullAccess) != nil {
            return true
        }
        if AppGroupStorage.shared.get(Date.self, for: "keyboard_last_loaded") != nil {
            return true
        }
        return false
    }

    @Published private(set) var isKeyboardEnabled: Bool = false
    @Published private(set) var hasFullAccessState: Bool = false

    /// Returns true if full access has been confirmed by the keyboard extension
    var hasFullAccessConfirmed: Bool {
        // The keyboard extension writes this to App Group storage when it loads
        return AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.keyboardHasFullAccess) ?? false
    }

    /// Tracks if user has opened Settings for full access step
    @Published var hasOpenedFullAccessSettings: Bool = false
    /// Tracks if user has opened Settings for keyboard enable step
    @Published var hasOpenedKeyboardSettings: Bool = false
    @Published private(set) var statusRefresh: Int = 0

    init() {
        hasOpenedFullAccessSettings = AppGroupStorage.shared.get(
            Bool.self,
            for: AppGroupKeys.fullAccessSettingsOpened
        ) ?? false
        hasOpenedKeyboardSettings = AppGroupStorage.shared.get(
            Bool.self,
            for: AppGroupKeys.keyboardSettingsOpened
        ) ?? false
    }

    var hasFullAccess: Bool {
        // Priority 1: If keyboard extension has confirmed full access, use that (most reliable)
        let enabled = isKeyboardExtensionEnabled
        return computeHasFullAccess(isKeyboardEnabled: enabled)
    }

    /// Indicates if the user needs to type with the keyboard to update status
    var needsKeyboardActivation: Bool {
        return !hasKeyboardBeenActivated
    }

    func markFullAccessSettingsOpened() {
        hasOpenedFullAccessSettings = true
        AppGroupStorage.shared.set(true, for: AppGroupKeys.fullAccessSettingsOpened)
        AppGroupStorage.shared.synchronize()
    }

    func markKeyboardSettingsOpened() {
        hasOpenedKeyboardSettings = true
        AppGroupStorage.shared.set(true, for: AppGroupKeys.keyboardSettingsOpened)
        AppGroupStorage.shared.synchronize()
    }

    func refreshStatus() {
        // Force synchronize to get latest values from App Group
        // synchronize() doesn't throw, but we'll add defensive check anyway
        UserDefaults.standard.synchronize()
        AppGroupStorage.shared.synchronize()

        let enabled = computeIsKeyboardExtensionEnabled()
        let fullAccess = computeHasFullAccess(isKeyboardEnabled: enabled)

        if isKeyboardEnabled != enabled {
            isKeyboardEnabled = enabled
        }
        if hasFullAccessState != fullAccess {
            hasFullAccessState = fullAccess
        }

        // Trigger a lightweight refresh for any views observing this service.
        statusRefresh &+= 1
    }

    /// Marks that the user has been prompted to activate the keyboard
    /// Called when showing the "type something" prompt
    func markActivationPromptShown() {
        AppGroupStorage.shared.set(true, for: AppGroupKeys.activationPromptShown)
        AppGroupStorage.shared.synchronize()
    }

    var wasActivationPromptShown: Bool {
        return AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.activationPromptShown) ?? false
    }

    var isKeyboardExtensionEnabled: Bool {
        computeIsKeyboardExtensionEnabled()
    }

    private func computeIsKeyboardExtensionEnabled() -> Bool {
        // Priority 1: Check if keyboard has written to App Group (most reliable)
        // This means the keyboard was actually used
        if hasKeyboardBeenActivated {
            return true
        }

        // Priority 2: Check UITextInputMode.activeInputModes
        let inputModes = UITextInputMode.activeInputModes
        for mode in inputModes {
            if let identifier = mode.value(forKey: "identifier") as? String,
               identifier.contains(keyboardBundleId) {
                return true
            }
        }

        // Priority 3: If user opened Settings for this step, optimistically return true
        // This allows the UI to progress while user completes setup
        if hasOpenedKeyboardSettings {
            return true
        }

        return false
    }

    private func computeHasFullAccess(isKeyboardEnabled: Bool) -> Bool {
        // Priority 1: If keyboard extension has confirmed full access, use that (most reliable)
        let activated = hasKeyboardBeenActivated

        if activated {
            let confirmed = hasFullAccessConfirmed
            let result = confirmed
            return result
        }

        // Priority 2: If keyboard is enabled AND user has opened Settings, allow progression
        // This handles the case where user enabled full access but hasn't used keyboard yet
        // The keyboard extension will write the actual status when it first loads
        let openedSettings = hasOpenedFullAccessSettings

        if isKeyboardEnabled && openedSettings {
            // Check if there's a stored value (even if false) - means keyboard extension loaded
            // If no value exists yet, assume full access is enabled if user went through Settings
            // This prevents blocking the user when they've enabled full access but keyboard hasn't loaded
            if let storedValue = AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.keyboardHasFullAccess) {
                // Value exists - use it (keyboard extension has loaded)
                return storedValue
            } else {
                // No value yet - keyboard extension hasn't loaded, but user enabled it in Settings
                // Return true optimistically - keyboard extension will correct it when it loads
                return true
            }
        }

        return false
    }
}
