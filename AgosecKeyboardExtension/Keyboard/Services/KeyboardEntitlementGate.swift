import Foundation
import SharedCore
import Networking

class KeyboardEntitlementGate {
    
    func verifyEntitlement() async {
        guard let accessToken: String = AppGroupStorage.shared.get(String.self, for: "access_token") else {
            return
        }
        
        let client = APIClient(baseURL: Config.shared.backendBaseUrl)
        let entitlementAPI = EntitlementAPI(client: client, accessToken: accessToken)
        
        do {
            let entitlement = try await entitlementAPI.fetchEntitlement()
            AppGroupStorage.shared.set(entitlement, for: "entitlement_state")
        } catch {
            print("Failed to verify entitlement: \(error)")
        }
    }
    
    func isEntitled() -> Bool {
        if let entitlement: EntitlementState = AppGroupStorage.shared.get(EntitlementState.self, for: "entitlement_state") {
            return entitlement.isValid
        }
        return false
    }
}