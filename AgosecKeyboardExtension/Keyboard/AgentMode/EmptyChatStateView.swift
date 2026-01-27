import SwiftUI
import UIComponents

struct EmptyChatStateView: View {
    var body: some View {
        let iconSize: CGFloat = ResponsiveSystem.value(extraSmall: 52, small: 58, standard: 64)
        let ringSize: CGFloat = ResponsiveSystem.value(extraSmall: 88, small: 98, standard: 110)
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding = min(screenWidth * 0.12, 48)

        VStack(spacing: ResponsiveSystem.value(extraSmall: 12, small: 16, standard: 20)) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.3),
                                Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: ringSize, height: ringSize)

                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: ringSize * 0.75, height: ringSize * 0.75)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )

                Image(systemName: "message.fill")
                    .font(.system(size: iconSize * 0.6, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0),
                                Color(red: 0.58, green: 0.0, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: ResponsiveSystem.value(extraSmall: 6, small: 8, standard: 10)) {
                Text("Start a conversation")
                    .font(.system(size: ResponsiveSystem.value(extraSmall: 18, small: 20, standard: 22), weight: .bold))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))

                Text("Ask me anything or share a screenshot for context")
                    .font(.system(size: ResponsiveSystem.value(extraSmall: 13, small: 14, standard: 15)))
                    .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, horizontalPadding)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
}
