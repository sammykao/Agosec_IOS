import UIKit

enum LogoLoader {
    private static let logoName = "agosec_logo"
    private static let mainAppBundleIdKey = "MAIN_APP_BUNDLE_ID"

    static func loadAgosecLogo() -> UIImage? {
        let mainBundle = Bundle.main
        if let image = UIImage(named: logoName, in: mainBundle, compatibleWith: nil) {
            return image
        }

        if let image = UIImage(named: logoName) {
            return image
        }

        if let mainAppBundleId = resolveMainAppBundleId(),
           let mainAppBundle = Bundle(identifier: mainAppBundleId),
           let image = UIImage(named: logoName, in: mainAppBundle, compatibleWith: nil) {
            return image
        }

        let containingAppBundle = mainBundle.bundleURL
            .deletingLastPathComponent()
            .appendingPathComponent("AgosecApp.app")
            .path
        if let bundle = Bundle(path: containingAppBundle),
           let image = UIImage(named: logoName, in: bundle, compatibleWith: nil) {
            return image
        }

        return nil
    }

    private static func resolveMainAppBundleId() -> String? {
        if let override = Bundle.main.object(forInfoDictionaryKey: mainAppBundleIdKey) as? String,
           !override.isEmpty {
            return override
        }

        guard let bundleId = Bundle.main.bundleIdentifier else {
            return nil
        }

        let suffix = ".extension"
        guard bundleId.hasSuffix(suffix) else {
            return nil
        }

        return String(bundleId.dropLast(suffix.count))
    }
}
