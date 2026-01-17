import Foundation
import UIKit
import SharedCore

class PermissionsService: ObservableObject {
    
    // Bundle ID must match what's in project.yml
    private let keyboardBundleId = "io.agosec.keyboard.app.keyboard"
    
    var isKeyboardExtensionEnabled: Bool {
        // Check if our keyboard appears in the enabled keyboards list
        guard let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] else {
            return false
        }
        return keyboards.contains(keyboardBundleId)
    }
    
    var hasFullAccess: Bool {
        // The keyboard extension writes this to App Group storage when it loads
        return AppGroupStorage.shared.get(Bool.self, for: "keyboard_has_full_access") ?? false
    }
    
    func refreshStatus() {
        objectWillChange.send()
    }
}