import SwiftUI
import SharedCore

/// Debug view to read logs from keyboard extension
struct LogViewer: View {
    @State private var logs: String = "Loading logs..."
    @State private var lastUpdate: Date = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Last Updated: \(lastUpdate, style: .time)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Button("Refresh") {
                            loadLogs()
                        }
                        .buttonStyle(.bordered)

                        Button("Clear") {
                            FileLogger.shared.clearLogs()
                            loadLogs()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                    .padding()

                    Text(logs)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .navigationTitle("Debug Logs")
            .onAppear {
                loadLogs()
            }
        }
    }

    private func loadLogs() {
        logs = FileLogger.shared.readLogs()
        lastUpdate = Date()
    }
}
