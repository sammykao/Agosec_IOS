import KeyboardKit

extension KeyboardApp {
    
    static var agosec: KeyboardApp {
        .init(
            name: "Agosec",
            licenseKey: nil, // Free tier - no license key needed
            appGroupId: "group.io.agosec.keyboard",
            locales: [Locale(identifier: "en")], // English locale
            deepLinks: .init(
                app: "agosec://"
            )
        )
    }
}
