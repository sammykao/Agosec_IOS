import UIKit

class ClipboardService {
    static let shared = ClipboardService()

    private init() {}

    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    func getFromClipboard() -> String? {
        return UIPasteboard.general.string
    }
}
