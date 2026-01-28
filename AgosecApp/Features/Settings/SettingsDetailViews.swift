import SwiftUI
import UIComponents

struct KeyboardSettingsView: View {
    @AppStorage("autocorrect_enabled") private var autocorrectEnabled = true
    @AppStorage("predictive_text") private var predictiveText = true
    @AppStorage("caps_lock_enabled") private var capsLockEnabled = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SettingsBackground()
                .ignoresSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: ResponsiveSystem.isSmallScreen ? 14 : 18) {
                    SettingsHeader(
                        title: "Keyboard",
                        icon: "chevron.left",
                        action: { dismiss() }
                    )

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionTitle(text: "Typing")

                            SettingsToggleRow(title: "Auto-Correction", isOn: $autocorrectEnabled)
                            SettingsToggleRow(title: "Predictive Text", isOn: $predictiveText)
                            SettingsToggleRow(title: "Enable Caps Lock", isOn: $capsLockEnabled)
                        }
                    }

                    NavigationLink(destination: AISettingsView()) {
                        SettingsRowLabel(
                            icon: "brain.head.profile",
                            title: "AI Assistant",
                            subtitle: "Response and context settings"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
                .padding(.top, ResponsiveSystem.isShortScreen ? 14 : 20)
                .padding(.bottom, ResponsiveSystem.isShortScreen ? 24 : 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarHidden(true)
    }
}

struct AISettingsView: View {
    @AppStorage("ai_suggestions_enabled") private var aiSuggestionsEnabled = true
    @AppStorage("ai_context_enabled") private var aiContextEnabled = true
    @AppStorage("ai_response_length") private var aiResponseLength = "medium"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SettingsBackground()
                .ignoresSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: ResponsiveSystem.isSmallScreen ? 14 : 18) {
                    SettingsHeader(
                        title: "AI Assistant",
                        icon: "chevron.left",
                        action: { dismiss() }
                    )

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionTitle(text: "Features")

                            SettingsToggleRow(title: "AI Suggestions", isOn: $aiSuggestionsEnabled)
                            SettingsToggleRow(title: "Context from Screenshots", isOn: $aiContextEnabled)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionTitle(text: "Response Style")

                            Picker("Length", selection: $aiResponseLength) {
                                Text("Short").tag("short")
                                Text("Medium").tag("medium")
                                Text("Long").tag("long")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .accentColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                        }
                    }
                }
                .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 20 : 24)
                .padding(.top, ResponsiveSystem.isShortScreen ? 14 : 20)
                .padding(.bottom, ResponsiveSystem.isShortScreen ? 24 : 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarHidden(true)
    }
}
