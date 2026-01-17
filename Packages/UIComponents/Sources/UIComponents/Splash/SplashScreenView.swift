import SwiftUI
import UIKit

/// A sleek, modern splash screen with physics-based animations and techy design
public struct SplashScreenView: View {
    let logoName: String
    let appName: String
    
    // Logo animation states
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0.0
    @State private var logoGlow: CGFloat = 0.0
    @State private var logoFloat: CGFloat = 0
    
    // Orbital ring states
    @State private var ringRotation: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    
    // Particle system states
    @State private var particles: [OrbitalParticle] = []
    @State private var energyWaveScale: CGFloat = 0.8
    @State private var energyWaveOpacity: Double = 0.6
    
    // Text states
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 20
    
    // Grid lines
    @State private var gridOpacity: Double = 0
    
    public init(logoName: String = "agosec_logo", appName: String = "Agosec") {
        self.logoName = logoName
        self.appName = appName
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark gradient background for techy feel
                techBackground
                
                // Animated grid lines
                TechGridView(opacity: gridOpacity)
                
                // Energy waves emanating from center
                energyWaves(in: geometry)
                
                // Orbital particles
                ForEach(particles) { particle in
                    OrbitalParticleView(particle: particle)
                }
                
                // Main content
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo with orbital rings
                    ZStack {
                        // Outer orbital rings
                        orbitalRings
                        
                        // Glow effect behind logo
                        logoGlowEffect
                        
                        // Main logo
                        logoView
                    }
                    .frame(width: 200, height: 200)
                    
                    Spacer().frame(height: 40)
                    
                    // App name with glow
                    Text(appName)
                        .font(.system(size: 42, weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color.white.opacity(0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.blue.opacity(0.5), radius: 20, x: 0, y: 0)
                        .shadow(color: Color.cyan.opacity(0.3), radius: 10, x: 0, y: 0)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                    
                    // Tagline
                    Text("AI-Powered Intelligence")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(Color.white.opacity(0.6))
                        .tracking(2)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    // Loading indicator
                    TechLoadingIndicator()
                        .opacity(textOpacity)
                        .padding(.bottom, 60)
                }
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            initializeParticles()
            startAnimations()
        }
    }
    
    // MARK: - Background
    
    private var techBackground: some View {
        ZStack {
            // Deep dark gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.02, green: 0.02, blue: 0.08)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Radial glow in center
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.05),
                    Color.clear
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
        }
    }
    
    // MARK: - Energy Waves
    
    private func energyWaves(in geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.3),
                                Color.blue.opacity(0.2),
                                Color.purple.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 200 + CGFloat(index) * 80, height: 200 + CGFloat(index) * 80)
                    .scaleEffect(energyWaveScale + CGFloat(index) * 0.1)
                    .opacity(energyWaveOpacity - Double(index) * 0.15)
            }
        }
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 40)
    }
    
    // MARK: - Orbital Rings
    
    private var orbitalRings: some View {
        ZStack {
            // Inner ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.cyan.opacity(0.6),
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.2),
                            Color.cyan.opacity(0.6)
                        ]),
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: 170, height: 170)
                .rotationEffect(.degrees(ringRotation))
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
            
            // Outer ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.4),
                            Color.blue.opacity(0.2),
                            Color.cyan.opacity(0.3),
                            Color.purple.opacity(0.4)
                        ]),
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 195, height: 195)
                .rotationEffect(.degrees(-ringRotation * 0.7))
                .scaleEffect(ringScale)
                .opacity(ringOpacity * 0.7)
        }
    }
    
    // MARK: - Logo Views
    
    private var logoGlowEffect: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.cyan.opacity(0.4 * logoGlow),
                        Color.blue.opacity(0.2 * logoGlow),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 30,
                    endRadius: 100
                )
            )
            .frame(width: 200, height: 200)
            .blur(radius: 20)
    }
    
    private var logoView: some View {
        Group {
            if let uiImage = UIImage(named: logoName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "cpu")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .frame(width: 140, height: 140)
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
        .offset(y: logoFloat)
        .shadow(color: Color.cyan.opacity(0.5), radius: 30, x: 0, y: 0)
        .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 5)
    }
    
    // MARK: - Animations
    
    private func initializeParticles() {
        particles = (0..<12).map { index in
            OrbitalParticle(
                id: index,
                angle: Double(index) * 30,
                radius: CGFloat.random(in: 100...150),
                speed: Double.random(in: 0.3...0.8),
                size: CGFloat.random(in: 3...6),
                opacity: Double.random(in: 0.4...0.8)
            )
        }
    }
    
    private func startAnimations() {
        // Grid fade in
        withAnimation(.easeOut(duration: 0.8)) {
            gridOpacity = 0.3
        }
        
        // Logo entrance with spring physics
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Logo glow pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            logoGlow = 1.0
        }
        
        // Logo floating
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            logoFloat = -8
        }
        
        // Orbital rings
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.5)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }
            
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
        
        // Energy waves
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            energyWaveScale = 1.2
            energyWaveOpacity = 0.3
        }
        
        // Text entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                textOpacity = 1.0
                textOffset = 0
            }
        }
        
        // Animate particles
        animateParticles()
    }
    
    private func animateParticles() {
        for index in particles.indices {
            withAnimation(.linear(duration: 8 / particles[index].speed).repeatForever(autoreverses: false)) {
                particles[index].angle += 360
            }
        }
    }
}

// MARK: - Supporting Views

struct OrbitalParticle: Identifiable {
    let id: Int
    var angle: Double
    let radius: CGFloat
    let speed: Double
    let size: CGFloat
    let opacity: Double
}

struct OrbitalParticleView: View {
    let particle: OrbitalParticle
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.cyan.opacity(particle.opacity),
                        Color.blue.opacity(particle.opacity * 0.5),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size
                )
            )
            .frame(width: particle.size * 2, height: particle.size * 2)
            .offset(
                x: cos(particle.angle * .pi / 180) * particle.radius,
                y: sin(particle.angle * .pi / 180) * particle.radius
            )
            .blur(radius: 1)
    }
}

struct TechGridView: View {
    let opacity: Double
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let spacing: CGFloat = 40
                
                // Vertical lines
                for x in stride(from: 0, through: size.width, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(Color.cyan.opacity(0.1)), lineWidth: 0.5)
                }
                
                // Horizontal lines
                for y in stride(from: 0, through: size.height, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(Color.cyan.opacity(0.1)), lineWidth: 0.5)
                }
            }
        }
        .opacity(opacity)
    }
}

struct TechLoadingIndicator: View {
    @State private var rotation: Double = 0
    @State private var dotScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.cyan.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .scaleEffect(dotScale)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: dotScale
                    )
            }
        }
        .onAppear {
            dotScale = 0.5
        }
    }
}
