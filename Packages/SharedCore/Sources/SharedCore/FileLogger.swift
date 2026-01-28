import Foundation

/// File-based logger for keyboard extensions where console logging is unreliable
public class FileLogger {
    public static let shared = FileLogger()

    private let appGroupId: String = {
        if let configuredId = Bundle.main.object(forInfoDictionaryKey: "APP_GROUP_ID") as? String,
           !configuredId.isEmpty {
            return configuredId
        }
        return "group.io.agosec.keyboard"
    }()
    private let logFileName = "debug_log.txt"
    private let maxLogSize: Int = 100_000 // 100KB max log file
    private let logQueue = DispatchQueue(label: "io.agosec.filelogger", qos: .utility)

    private init() {}

    /// Get the log file URL in App Group container
    private var logFileURL: URL? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        ) else {
            // CRITICAL: Log to a fallback location if App Group doesn't exist
            let fallbackPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("keyboard_debug_log.txt")
            let errorMsg = "⚠️ [FileLogger] App Group container not found! Using fallback: " +
                "\(fallbackPath?.path ?? "none")"
            print(errorMsg)
            NSLog(errorMsg)
            return fallbackPath
        }
        return containerURL.appendingPathComponent(logFileName)
    }

    /// Log a message to file with async disk writes
    public func log(_ message: String, level: LogLevel = .info) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] [\(level.rawValue)] \(message)\n"

        // Also print/NSLog for console (if available) - ALWAYS do this first
        print(logEntry.trimmingCharacters(in: .whitespacesAndNewlines))
        NSLog("%@", logEntry.trimmingCharacters(in: .whitespacesAndNewlines))
        fflush(stdout)
        logQueue.async { [weak self] in
            self?.writeLogEntry(logEntry)
        }
    }

    private func writeLogEntry(_ logEntry: String) {
        guard hasAppGroupContainer else {
            handleMissingAppGroup(logEntry)
            return
        }

        writeRecentLogsToUserDefaults(logEntry)
        writeToFile(logEntry)
        trimLogFileIfNeeded()
    }

    private var hasAppGroupContainer: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) != nil
    }

    private func handleMissingAppGroup(_ logEntry: String) {
        let errorMsg = "⚠️ [FileLogger] App Group '\(appGroupId)' does not exist! " +
            "Logs will only go to console/NSLog."
        print(errorMsg)
        NSLog(errorMsg)
        writeRecentLogsToUserDefaults(logEntry)
    }

    private func writeRecentLogsToUserDefaults(_ logEntry: String) {
        guard let defaults = UserDefaults(suiteName: appGroupId) else { return }
        let existing = defaults.string(forKey: "last_5_logs") ?? ""
        let newLogs = (existing + logEntry).components(separatedBy: "\n").suffix(5).joined(separator: "\n")
        defaults.set(newLogs, forKey: "last_5_logs")
        defaults.set(logEntry.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "last_log")
        defaults.synchronize()
    }

    private func writeFallbackDataToUserDefaults(_ logEntry: String) {
        guard let data = logEntry.data(using: .utf8),
              let defaults = UserDefaults(suiteName: appGroupId) else { return }
        defaults.set(data, forKey: "last_debug_log")
        defaults.synchronize()
    }

    private func writeToFile(_ logEntry: String) {
        guard let fileURL = logFileURL else {
            writeFallbackDataToUserDefaults(logEntry)
            return
        }

        do {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                try "".write(to: fileURL, atomically: true, encoding: .utf8)
            }

            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                if let data = logEntry.data(using: .utf8) {
                    fileHandle.write(data)
                    fileHandle.synchronizeFile()
                    fileHandle.closeFile()
                }
            } else if let existing = try? String(contentsOf: fileURL, encoding: .utf8) {
                try (existing + logEntry).write(to: fileURL, atomically: true, encoding: .utf8)
            } else {
                try logEntry.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            writeFallbackDataToUserDefaults(logEntry)
        }
    }

    /// Read all log entries
    public func readLogs() -> String {
        guard let fileURL = logFileURL,
              let data = try? Data(contentsOf: fileURL),
              let content = String(data: data, encoding: .utf8) else {
            return "No logs available"
        }
        return content
    }

    /// Clear log file
    public func clearLogs() {
        guard let fileURL = logFileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }

    /// Trim log file if it exceeds max size
    private func trimLogFileIfNeeded() {
        guard let fileURL = logFileURL,
              let data = try? Data(contentsOf: fileURL),
              data.count > maxLogSize else {
            return
        }

        // Keep only the last 50KB
        let keepSize = 50_000
        let trimmedData = data.suffix(keepSize)
        try? trimmedData.write(to: fileURL)
    }

    public enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case critical = "CRITICAL"
    }
}

private extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}
