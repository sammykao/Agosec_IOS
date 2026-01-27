import SwiftUI
import UIKit

extension View {
    func onAppBecameActive(perform action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            action()
        }
    }
}
