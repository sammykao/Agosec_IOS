import SwiftUI

/// Overlay view that displays toast messages globally
public struct ToastOverlay: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toastManager.currentToast {
                VStack {
                    Spacer()
                    ToastView(
                        message: toast.message,
                        type: toast.type,
                        retryAction: toast.retryAction
                    )
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: toastManager.currentToast != nil)
                }
            }
        }
    }
}

public extension View {
    func toastOverlay(toastManager: ToastManager) -> some View {
        modifier(ToastOverlay(toastManager: toastManager))
    }
}

