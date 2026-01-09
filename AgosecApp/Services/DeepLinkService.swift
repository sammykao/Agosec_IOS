import Foundation
import UIKit
import Combine

class DeepLinkService: ObservableObject {
    static let shared = DeepLinkService()
    
    // Publisher for deep link navigation
    @Published var navigationRequest: DeepLinkNavigation?
    
    enum DeepLinkNavigation {
        case paywall
        case settings
    }
    
    private init() {}
    
    func handle(url: URL) {
        guard url.scheme == "agosec" else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let path = components?.path ?? ""
        
        DispatchQueue.main.async {
            switch path {
            case "/subscribe", "/paywall":
                self.navigationRequest = .paywall
            case "/settings":
                self.navigationRequest = .settings
            default:
                break
            }
        }
    }
    
    func clearNavigation() {
        navigationRequest = nil
    }
}