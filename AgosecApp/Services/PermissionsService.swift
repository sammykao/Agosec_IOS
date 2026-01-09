import Foundation
import UIKit

class PermissionsService: ObservableObject {
    var isKeyboardExtensionEnabled: Bool {
        guard let keyboards = UserDefaults.standard.array(forKey: "AppleKeyboards") as? [[String: Any]] else {
            return false
        }
        
        let bundleId = "io.agosec.keyboard.extension"
        return keyboards.contains { keyboard in
            guard let identifier = keyboard["BundleIdentifier"] as? String else { return false }
            return identifier == bundleId
        }
    }
    
    var hasFullAccess: Bool {
        return UserDefaults.standard.bool(forKey: "com.apple.keyboard.extension.hasFullAccess")
    }
}