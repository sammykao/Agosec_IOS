import Foundation
import UIKit
import SharedCore

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
        // If we have any value stored (even false), the keyboard has been used
        return AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.keyboardHasFullAccess) != nil
    }
    
    var isKeyboardExtensionEnabled: Bool {
        // Primary check: AppleKeyboards in UserDefaults
        // This key contains bundle IDs of all enabled keyboards
        if let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] {
            if keyboards.contains(keyboardBundleId) {
                return true
            }
        }
        
        // iOS sometimes stores enabled keyboards in AppleKeyboardsExpanded
        if let keyboardsExpanded = UserDefaults.standard.object(forKey: "AppleKeyboardsExpanded") as? [String] {
            if keyboardsExpanded.contains(keyboardBundleId) {
                return true
            }
        }
        
        // Fallback: Check if keyboard was ever activated via App Group
        // If the keyboard wrote to App Group, it must have been enabled at some point
        if hasKeyboardBeenActivated {
            return true
        }
        
        return false
    }
    
    /// Returns true if full access has been confirmed by the keyboard extension
    var hasFullAccessConfirmed: Bool {
        // The keyboard extension writes this to App Group storage when it loads
        return AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.keyboardHasFullAccess) ?? false
    }
    
    /// Tracks if user has opened Settings for full access step
    @Published var hasOpenedFullAccessSettings: Bool = false
    @Published private(set) var statusRefresh: Int = 0
    
    var hasFullAccess: Bool {
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
        let enabled = isKeyboardExtensionEnabled
        let openedSettings = hasOpenedFullAccessSettings
        
        if enabled && openedSettings {
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
    
    /// Indicates if the user needs to type with the keyboard to update status
    var needsKeyboardActivation: Bool {
        return !hasKeyboardBeenActivated
    }
    
    func markFullAccessSettingsOpened() {
        hasOpenedFullAccessSettings = true
    }
    
    func refreshStatus() {
        // Force synchronize to get latest values from App Group
        // synchronize() doesn't throw, but we'll add defensive check anyway
        AppGroupStorage.shared.synchronize()

        // Trigger a lightweight refresh for any views observing this service.
        DispatchQueue.main.async {
            self.statusRefresh &+= 1
        }
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
}
