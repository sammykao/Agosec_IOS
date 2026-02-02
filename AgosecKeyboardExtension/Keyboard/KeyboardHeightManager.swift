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
            return keyboardContext.screenSize.height * 0.75
        }
    }

    private func standardKeyboardHeight(for context: KeyboardContext) -> CGFloat {
        let layout = keyboardLayout(for: context)
        var deviceConfiguration = KeyboardLayout.DeviceConfiguration.standard(for: context)
        deviceConfiguration.inputToolbarHeight = 36
        let displayMode = context.settings.inputToolbarDisplayMode

        var configuredLayout = layout
        configuredLayout.deviceConfiguration = deviceConfiguration

        let adjustedLayout = configuredLayout.adjusted(
            for: displayMode,
            layoutConfiguration: deviceConfiguration
        )

        let toolbarHeight = deviceConfiguration.inputToolbarHeight
        let adjustedHeight = CGFloat(adjustedLayout.totalHeight) - (toolbarHeight / 3)
        return adjustedHeight
    }

    private func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
        do {
            return try context.locale.keyboardLayout(for: context)
        } catch {
            return KeyboardLayout.standard(for: context)
        }
    }
}
