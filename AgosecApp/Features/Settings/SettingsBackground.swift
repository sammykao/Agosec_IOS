import SwiftUI

struct SettingsBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.08),
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.06, green: 0.06, blue: 0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            SettingsFloatingOrbs()
        }
    }
}

struct SettingsFloatingOrbs: View {
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.18 - Double(index) * 0.05),
                                Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.14 - Double(index) * 0.04),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 120 + CGFloat(index) * 60
                        )
                    )
                    .frame(width: 220 + CGFloat(index) * 90, height: 220 + CGFloat(index) * 90)
                    .blur(radius: 50)
                    .offset(
                        x: CGFloat(index) * 70 - 120,
                        y: CGFloat(index) * 90 - 180
                    )
                    .opacity(0.65)
            }
        }
    }
}
