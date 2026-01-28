import SwiftUI

/// Shared animated glassmorphic background used by onboarding and splash screens.
public struct GlassmorphicBackground: View {
    private let orbCount: Int
    private let showOrbs: Bool
    private let animate: Bool

    @State private var gradientOffset: CGFloat = 0
    @State private var orbPositions: [CGPoint] = []
    @State private var orbOpacity: Double = 0

    public init(orbCount: Int = 4, showOrbs: Bool = true, animate: Bool = true) {
        self.orbCount = max(0, orbCount)
        self.showOrbs = showOrbs
        self.animate = animate
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.08),
                        Color(red: 0.08, green: 0.08, blue: 0.12),
                        Color(red: 0.06, green: 0.06, blue: 0.1)
                    ]),
                    startPoint: UnitPoint(x: 0.5 + gradientOffset, y: 0),
                    endPoint: UnitPoint(x: 0.5 - gradientOffset, y: 1)
                )

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.2),
                        Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.1),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 600
                )

                if showOrbs {
                    floatingOrbs(in: geometry)
                }
            }
            .onAppear {
                initializeOrbs()
                if animate {
                    startAnimations()
                }
            }
        }
    }

    private func floatingOrbs(in geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<orbCount, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.2 - Double(index) * 0.04),
                                Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.15 - Double(index) * 0.03),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 100 + CGFloat(index) * 50
                        )
                    )
                    .frame(
                        width: min(200 + CGFloat(index) * 80, geometry.size.width * 0.6),
                        height: min(200 + CGFloat(index) * 80, geometry.size.width * 0.6)
                    )
                    .blur(radius: 40)
                    .offset(
                        x: orbPositions.indices.contains(index)
                            ? clamp(
                                orbPositions[index].x,
                                min: -geometry.size.width * 0.3,
                                max: geometry.size.width * 0.3
                            )
                            : 0,
                        y: orbPositions.indices.contains(index)
                            ? clamp(
                                orbPositions[index].y,
                                min: -geometry.size.height * 0.3,
                                max: geometry.size.height * 0.3
                            )
                            : 0
                    )
                    .opacity(orbOpacity * (1.0 - Double(index) * 0.15))
            }
        }
    }

    private func initializeOrbs() {
        orbPositions = initialOrbPositions(count: orbCount)
        withAnimation(.easeOut(duration: 1.0)) {
            orbOpacity = 1.0
        }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
            gradientOffset = 0.15
        }
        animateOrbs()
    }

    private func animateOrbs() {
        for index in orbPositions.indices {
            withAnimation(
                .easeInOut(duration: 4.0 + Double(index) * 0.5)
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.3)
            ) {
                orbPositions[index].x += CGFloat.random(in: -30...30)
                orbPositions[index].y += CGFloat.random(in: -30...30)
            }
        }
    }

    private func initialOrbPositions(count: Int) -> [CGPoint] {
        guard count > 0 else { return [] }
        let base: [CGPoint] = [
            CGPoint(x: -100, y: -150),
            CGPoint(x: 80, y: -120),
            CGPoint(x: -60, y: 150),
            CGPoint(x: 120, y: 140)
        ]
        if count <= base.count {
            return Array(base.prefix(count))
        }
        var positions = base
        while positions.count < count {
            positions.append(CGPoint(x: CGFloat.random(in: -140...140), y: CGFloat.random(in: -180...180)))
        }
        return positions
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }
}
