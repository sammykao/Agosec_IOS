import SwiftUI
import SharedCore

/// Simple view to check debug status from UserDefaults
struct DebugStatusView: View {
    @State private var lastStep: String = "Unknown"
    @State private var lastLog: String = "No logs"
    @State private var last5Logs: String = "No logs"

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Debug Status")
                    .font(.title)
                    .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Step:")
                        .font(.headline)
                    Text(lastStep)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Log:")
                        .font(.headline)
                    Text(lastLog)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Last 5 Logs:")
                        .font(.headline)
                    ScrollView {
                        Text(last5Logs)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()

                Button("Refresh") {
                    loadStatus()
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Spacer()
            }
            .navigationTitle("Debug Status")
            .onAppear {
                loadStatus()
            }
        }
    }

    private func loadStatus() {
        if let defaults = UserDefaults(suiteName: "group.io.agosec.keyboard") {
            lastStep = defaults.string(forKey: "debug_step") ?? "Unknown"
            lastLog = defaults.string(forKey: "last_log") ?? "No logs"
            last5Logs = defaults.string(forKey: "last_5_logs") ?? "No logs"
        }
    }
}
