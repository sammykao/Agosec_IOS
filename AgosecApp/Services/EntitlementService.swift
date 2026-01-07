import Foundation
import Combine
import SharedCore
import Networking

class EntitlementService: ObservableObject {
    @Published var entitlementState: EntitlementState = EntitlementState(isActive: false)
    
    private var timer: Timer?
    
    init() {
        loadEntitlement()
        startPeriodicRefresh()
    }
    
    func loadEntitlement() {
        if let stored: EntitlementState = AppGroupStorage.shared.get(EntitlementState.self, for: "entitlement_state") {
            entitlementState = stored
        }
    }
    
    func refreshEntitlement() async {
        guard let accessToken: String = AppGroupStorage.shared.get(String.self, for: "access_token") else {
            return
        }
        
        let client = APIClient(baseURL: Config.shared.backendBaseUrl)
        let entitlementAPI = EntitlementAPI(client: client, accessToken: accessToken)
        
        do {
            let entitlement = try await entitlementAPI.fetchEntitlement()
            await MainActor.run {
                entitlementState = entitlement
                AppGroupStorage.shared.set(entitlement, for: "entitlement_state")
            }
        } catch {
            print("Failed to refresh entitlement: \(error)")
        }
    }
    
    private func startPeriodicRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            Task {
                await self.refreshEntitlement()
            }
        }
    }
}