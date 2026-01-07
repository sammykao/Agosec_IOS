import Foundation
import UIKit

class DeepLinkService {
    static let shared = DeepLinkService()
    
    private init() {}
    
    func handle(url: URL) {
        guard url.scheme == "agosec" else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let path = components?.path ?? ""
        
        switch path {
        case "/subscribe":
            handleSubscribe()
        case "/settings":
            handleSettings()
        default:
            break
        }
    }
    
    private func handleSubscribe() {
        NotificationCenter.default.post(name: .showPaywall, object: nil)
    }
    
    private func handleSettings() {
        NotificationCenter.default.post(name: .showSettings, object: nil)
    }
}

extension Notification.Name {
    static let showPaywall = Notification.Name("showPaywall")
    static let showSettings = Notification.Name("showSettings")
}