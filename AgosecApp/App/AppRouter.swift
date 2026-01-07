import SwiftUI
import SharedCore

class AppRouter: ObservableObject {
    @Published var currentRoute: Route = .onboarding
    
    enum Route {
        case onboarding
        case paywall
        case main
    }
    
    func navigateTo(_ route: Route) {
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
        .onReceive(entitlementService.$entitlementState) { state in
            if state.isValid {
                router.navigateTo(.main)
            }
        }
    }
}

struct MainAppView: View {
    @ObservedObject var router: AppRouter
    @EnvironmentObject var entitlementService: EntitlementService
    
    var body: some View {
        NavigationView {
            SettingsView()
                .navigationTitle("Agosec Keyboard")
                .navigationBarItems(trailing: subscriptionButton)
        }
    }
    
    private var subscriptionButton: some View {
        Button("Manage Subscription") {
            router.navigateTo(.paywall)
        }
    }
}