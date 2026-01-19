import Foundation
import UIKit
import SharedCore

class PermissionsService: ObservableObject {
    
    // Bundle ID must match what's in project.yml
    private let keyboardBundleId = "io.agosec.keyboard.app.keyboard"
    
    /// Tracks whether the keyboard has ever been activated (typed with)
    /// This is set to true when the keyboard extension writes full access status
    var hasKeyboardBeenActivated: Bool {
        // If we have any value stored (even false), the keyboard has been used
        return AppGroupStorage.shared.get(Bool.self, for: "keyboard_has_full_access") != nil
    }
    
    var isKeyboardExtensionEnabled: Bool {
        // Primary check: Check active input modes from system
        // This reflects the current state of enabled keyboards
        let activeInputModes = UITextInputMode.activeInputModes
        for mode in activeInputModes {
            if let identifier = mode.value(forKey: "identifier") as? String,
               identifier.contains("agosec") || identifier.contains("Agosec") {
                return true
            }
        }
        
        // Secondary check: AppleKeyboards in UserDefaults
        // This key contains bundle IDs of all enabled keyboards
        if let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] {
            if keyboards.contains(keyboardBundleId) {
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
    
    var hasFullAccess: Bool {
        // The keyboard extension writes this to App Group storage when it loads
        // Returns false if:
        // 1. Keyboard has never been used (nil -> false)
        // 2. Keyboard was used but full access is disabled (false -> false)
        return AppGroupStorage.shared.get(Bool.self, for: "keyboard_has_full_access") ?? false
    }
    
    /// Indicates if the user needs to type with the keyboard to update status
    var needsKeyboardActivation: Bool {
        return !hasKeyboardBeenActivated
    }
    
    func refreshStatus() {
        // Force synchronize to get latest values from App Group
        AppGroupStorage.shared.synchronize()
        objectWillChange.send()
    }
    
    /// Marks that the user has been prompted to activate the keyboard
    /// Called when showing the "type something" prompt
    func markActivationPromptShown() {
        AppGroupStorage.shared.set(true, for: "activation_prompt_shown")
        AppGroupStorage.shared.synchronize()
    }
    
    var wasActivationPromptShown: Bool {
        return AppGroupStorage.shared.get(Bool.self, for: "activation_prompt_shown") ?? false
    }
}