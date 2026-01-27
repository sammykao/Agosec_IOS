import Foundation

public class AppGroupStorage {
    public static let shared = AppGroupStorage()
    
    private let appGroupId: String
    private let userDefaults: UserDefaults
    
    private init() {
        if let configuredId = Bundle.main.object(forInfoDictionaryKey: "APP_GROUP_ID") as? String,
           !configuredId.isEmpty {
            self.appGroupId = configuredId
        } else {
            self.appGroupId = "group.io.agosec.keyboard"
        }
        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            // Use standard UserDefaults as fallback instead of crashing
            // This allows the app to continue functioning even if App Group isn't configured
            self.userDefaults = UserDefaults.standard
            return
        }
        self.userDefaults = defaults
    }

    public func set<T: Codable>(_ value: T, for key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key)
        } catch {}
    }
    
    public func get<T: Codable>(_ type: T.Type, for key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            let result = try JSONDecoder().decode(type, from: data)
            return result
        } catch {
            return nil
        }
    }
    
    public func remove(for key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    public func synchronize() {
        userDefaults.synchronize()
    }
}

public class KeychainHelper {
    public static let shared = KeychainHelper()
    
    private init() {}
    
    public func save(_ data: Data, service: String, account: String) -> Bool {
        let query = [
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        return status == errSecSuccess
    }
    
    public func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return result as? Data
    }
    
    public func delete(service: String, account: String) -> Bool {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        return status == errSecSuccess
    }
}
