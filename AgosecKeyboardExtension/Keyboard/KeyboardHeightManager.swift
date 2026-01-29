import UIKit
import KeyboardKit
import SharedCore

class KeyboardHeightManager {
    private weak var view: UIView?

    init(view: UIView) {
        self.view = view
    }

    func calculateHeight(mode: KeyboardMode, isExpanded: Bool, keyboardContext: KeyboardContext) -> CGFloat {
        switch mode {
        case .normal:
            return standardKeyboardHeight(for: keyboardContext)
        case .agent:
            return keyboardContext.screenSize.height * 0.80
        }
    }

    private func standardKeyboardHeight(for context: KeyboardContext) -> CGFloat {
        let layout = keyboardLayout(for: context)
        let deviceConfiguration = KeyboardLayout.DeviceConfiguration.standard(for: context)
        let displayMode = context.settings.inputToolbarDisplayMode

        var configuredLayout = layout
        configuredLayout.deviceConfiguration = deviceConfiguration

        let adjustedLayout = configuredLayout.adjusted(
            for: displayMode,
            layoutConfiguration: deviceConfiguration
        )

        return CGFloat(adjustedLayout.totalHeight)
    }

    private func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
        do {
            return try context.locale.keyboardLayout(for: context)
        } catch {
            return KeyboardLayout.standard(for: context)
        }
    }
}
