import Foundation

public enum AccessCopy {
    public static let enableKeyboardSteps: [String] = [
        "Open Settings → General → Keyboard",
        "Tap \"Keyboards\" → \"Add New Keyboard\"",
        "Select \"Agosec Keyboard\""
    ]

    public static let enableFullAccessSteps: [String] = [
        "Open Settings → General → Keyboard",
        "Tap \"Keyboards\" → \"Agosec Keyboard\"",
        "Toggle on \"Allow Full Access\""
    ]

    public static let fullAccessFooter = "Settings → Keyboards → Agosec → Full Access"
    public static let lockedViewFooter = "Tap keyboard switcher to change keyboards"
}
