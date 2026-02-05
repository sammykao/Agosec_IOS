import SwiftUI
import UIKit
import SharedCore
import UIComponents

struct MessageRowView: View {
    let message: ChatMessage
    let layout: AgentChatView.ChatLayout
    let onCopy: () -> Void
    let onAutofill: () -> Void
    let onReplace: () -> Void

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 0) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: layout.actionSpacing) {
                if message.isUser {
                    messageContent
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top, spacing: ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10)) {
                            Group {
                                if let uiImage = LogoLoader.loadAgosecLogo() {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Image(systemName: "sparkles")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(userBubbleGradient)
                                }
                            }
                            .frame(width: layout.avatarSize, height: layout.avatarSize)

                            assistantMessageContent
                        }

                        actionButtons
                    }
                }
            }

            if !message.isUser { Spacer(minLength: 0) }
        }
    }

    private var messageContent: some View {
        let fillStyle: AnyShapeStyle = message.isUser
            ? AnyShapeStyle(userBubbleGradient)
            : AnyShapeStyle(Color.white.opacity(0.92))

        return Text(message.content)
            .font(.system(size: layout.messageFontSize, weight: .regular))
            .lineSpacing(layout.messageLineSpacing)
            .foregroundColor(message.isUser ? .white : Color(red: 0.15, green: 0.15, blue: 0.2))
            .padding(layout.bubblePadding)
            .frame(maxWidth: layout.bubbleMaxWidth, alignment: message.isUser ? .trailing : .leading)
            .background(
                RoundedRectangle(cornerRadius: layout.bubbleCornerRadius)
                    .fill(fillStyle)
            )
            .overlay(
                RoundedRectangle(cornerRadius: layout.bubbleCornerRadius)
                    .stroke(
                        message.isUser
                            ? AnyShapeStyle(Color.white.opacity(0.25))
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.8), Color.blue.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            ),
                        lineWidth: 1
                    )
            )
            .shadow(color: message.isUser ? Color.blue.opacity(0.25) : Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .textSelection(.enabled)
    }

    private var assistantMessageContent: some View {
        Text(message.content)
            .font(.system(size: layout.messageFontSize, weight: .regular))
            .lineSpacing(layout.messageLineSpacing)
            .foregroundColor(Color.white.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
            .padding(.trailing, layout.bubblePadding)
            .textSelection(.enabled)
    }

    private var userBubbleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.48, blue: 1.0),
                Color(red: 0.58, green: 0.0, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var actionButtons: some View {
        ActionButtonsView(
            layout: layout,
            onCopy: onCopy,
            onAutofill: onAutofill,
            onReplace: onReplace
        )
    }
}

// MARK: - Action Buttons View

struct ActionButtonsView: View {
    let layout: AgentChatView.ChatLayout
    let onCopy: () -> Void
    let onAutofill: () -> Void
    let onReplace: () -> Void

    @State private var copyScale: CGFloat = 1.0
    @State private var insertScale: CGFloat = 1.0
    @State private var replaceScale: CGFloat = 1.0

    private var useCompactActions: Bool {
        ResponsiveSystem.isExtraSmallScreen || ResponsiveSystem.isSmallScreen
    }

    var body: some View {
        HStack(spacing: layout.actionSpacing) {
            if useCompactActions {
                actionIconButton(
                    title: "Copy",
                    systemImage: "doc.on.doc",
                    scale: $copyScale,
                    action: onCopy
                )

                actionIconButton(
                    title: "Insert",
                    systemImage: "text.insert",
                    scale: $insertScale,
                    action: onAutofill
                )

                actionIconButton(
                    title: "Replace",
                    systemImage: "arrow.2.squarepath",
                    scale: $replaceScale,
                    action: onReplace
                )
            } else {
                actionButton(
                    title: "Copy",
                    systemImage: "doc.on.doc",
                    scale: $copyScale,
                    action: onCopy
                )

                actionButton(
                    title: "Insert",
                    systemImage: "text.insert",
                    scale: $insertScale,
                    action: onAutofill
                )

                actionButton(
                    title: "Replace",
                    systemImage: "arrow.2.squarepath",
                    scale: $replaceScale,
                    action: onReplace
                )
            }
        }
        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
    }

    private func actionButton(
        title: String,
        systemImage: String,
        scale: Binding<CGFloat>,
        action: @escaping () -> Void
    ) -> some View {
        Button(
            action: {
                performAction(scale: scale, action: action)
            },
            label: {
                Label(title, systemImage: systemImage)
                    .font(.system(size: layout.actionFontSize, weight: .semibold))
                    .padding(.horizontal, layout.actionHorizontalPadding)
                    .padding(.vertical, layout.actionVerticalPadding)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.12))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                    )
                    .frame(minHeight: layout.minTapTarget)
                    .contentShape(Rectangle())
            }
        )
        .scaleEffect(scale.wrappedValue)
        .buttonStyle(PlainButtonStyle())
    }

    private func actionIconButton(
        title: String,
        systemImage: String,
        scale: Binding<CGFloat>,
        action: @escaping () -> Void
    ) -> some View {
        Button(
            action: {
                performAction(scale: scale, action: action)
            },
            label: {
                Image(systemName: systemImage)
                    .font(.system(size: layout.actionIconFontSize, weight: .semibold))
                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                    .frame(width: layout.actionIconButtonSize, height: layout.actionIconButtonSize)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                    )
                    .frame(minWidth: layout.minTapTarget, minHeight: layout.minTapTarget)
                    .contentShape(Rectangle())
                    .accessibilityLabel(title)
            }
        )
        .scaleEffect(scale.wrappedValue)
        .buttonStyle(PlainButtonStyle())
    }

    private func performAction(scale: Binding<CGFloat>, action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale.wrappedValue = 0.85
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale.wrappedValue = 1.0
            }
        }
        UIImpactFeedbackGenerator.safeImpact(.light)
        action()
    }
}
