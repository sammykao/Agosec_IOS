import SwiftUI
import KeyboardKit

struct KeyboardKitTypingView: View {
    let controller: KeyboardInputViewController
    
    init(controller: KeyboardInputViewController) {
        self.controller = controller
    }
    
    var body: some View {
        // Standard KeyboardKit keyboard view - use default implementation
        // KeyboardView automatically uses controller's state and services from environment
        return KeyboardView(
            services: controller.services,
            buttonContent: { item in
                item.view
            },
            buttonView: { item in
                item.view
            }
        )
    }
}
