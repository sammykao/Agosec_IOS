import SwiftUI
import SharedCore

class AppRouter: ObservableObject {
    @Published var currentRoute: Route = .onboarding
    
    enum Route {
        case onboarding
        case paywall
        case main
    }
    
    init() {
        // Check if onboarding is already complete
        if let isComplete: Bool = AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.onboardingComplete), isComplete {
            currentRoute = .main
        }
    }
    
    func navigateTo(_ route: Route) {
        // Ignore if already on the same route (for deep links)
        guard currentRoute != route else { return }
        currentRoute = route
    }
}

struct ContentView: View {
    @StateObject private var router = AppRouter()
    @EnvironmentObject var entitlementService: EntitlementService
    
    var body: some View {
        Group {
            switch router.currentRoute {
            case .onboarding:
                OnboardingCoordinator(router: router)
            case .paywall:
                PaywallView(router: router)
            case .main:
                MainAppView(router: router)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .onReceive(entitlementService.$entitlementState) { state in
            // Only auto-navigate to main if onboarding is complete
            // This prevents skipping onboarding steps when entitlement becomes valid
            let onboardingComplete = AppGroupStorage.shared.get(Bool.self, for: AppGroupKeys.onboardingComplete) ?? false
            
            if state.isValid && onboardingComplete {
                // Only navigate to main if we're not already on onboarding
                // This allows onboarding to complete naturally
                if router.currentRoute != .onboarding {
                    router.navigateTo(.main)
                }
            }
        }
        .onReceive(DeepLinkService.shared.$navigationRequest) { navigation in
            guard let navigation = navigation else { return }
            
            switch navigation {
            case .paywall:
                router.navigateTo(.paywall)
            case .settings:
                router.navigateTo(.main)
            }
            
            // Clear the navigation request after handling
            DeepLinkService.shared.clearNavigation()
        }
    }
}

// MainAppView moved to AgosecApp/Features/Main/MainAppView.swift
