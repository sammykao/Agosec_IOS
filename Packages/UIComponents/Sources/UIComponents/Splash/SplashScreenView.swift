import SwiftUI

/// A sleek, modern splash screen with logo and physics-based loading animations
public struct SplashScreenView: View {
    let logoName: String
    let appName: String
    
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var logoRotation: Double = -15
    @State private var logoYOffset: CGFloat = -30
    @State private var textOpacity: Double = 0.0
    @State private var textYOffset: CGFloat = 20
    @State private var pulseScale: CGFloat = 1.0
    @State private var particleOffsets: [CGPoint] = []
    @State private var particleOpacities: [Double] = []
    @State private var backgroundOffset: CGFloat = 0
    
    public init(logoName: String = "agosec_logo", appName: String = "Agosec") {
        self.logoName = logoName
        self.appName = appName
    }
    
    public var body: some View {
        ZStack {
            // Light gradient background with subtle animation
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.97, green: 0.97, blue: 0.99)
                ]),
                startPoint: UnitPoint(x: 0.5 + backgroundOffset, y: 0.5),
                endPoint: UnitPoint(x: 0.5 - backgroundOffset, y: 0.5)
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: backgroundOffset)
            
            // Subtle floating particles with light colors
            GeometryReader { geometry in
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.08),
                                    Color.purple.opacity(0.05),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .offset(
                            x: particleOffsets.indices.contains(index) ? particleOffsets[index].x : 0,
                            y: particleOffsets.indices.contains(index) ? particleOffsets[index].y : 0
                        )
                        .opacity(particleOpacities.indices.contains(index) ? particleOpacities[index] : 0)
                        .blur(radius: 30)
                }
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo with physics-based entrance animation
                ZStack {
                    // Subtle glowing rings with spring physics
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.15 - Double(index) * 0.05),
                                        Color.purple.opacity(0.12 - Double(index) * 0.04),
                                        Color.blue.opacity(0.15 - Double(index) * 0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: 160 + CGFloat(index) * 25, height: 160 + CGFloat(index) * 25)
                            .scaleEffect(pulseScale + CGFloat(index) * 0.08)
                            .opacity(0.4 - Double(index) * 0.1)
                            .rotationEffect(.degrees(Double(index) * 30))
                    }
                    
                    // Logo image with bouncy spring animation
                    Image(logoName, bundle: .main)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160, height: 160)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .offset(y: logoYOffset)
                        .rotationEffect(.degrees(logoRotation))
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                        .shadow(color: Color.blue.opacity(0.1), radius: 15, x: 0, y: 5)
                }
                
                // App name with clean, realistic font
                Text(appName)
                    .font(.system(size: 36, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .opacity(textOpacity)
                    .offset(y: textYOffset)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Background gradient animation
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            backgroundOffset = 0.2
        }
        
        // Logo entrance with spring physics
        withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
            logoRotation = 0
            logoYOffset = 0
        }
        
        // Text entrance with delayed spring bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
                textOpacity = 1.0
                textYOffset = 0
            }
        }
        
        // Continuous logo floating animation
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            logoYOffset = -8
        }
        
        // Pulse animation for rings
        withAnimation(.spring(response: 1.2, dampingFraction: 0.4).repeatForever(autoreverses: false)) {
            pulseScale = 1.2
        }
        
        // Initialize and animate particles
        initializeParticles()
        animateParticles()
    }
    
    private func initializeParticles() {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        
        for _ in 0..<8 {
            particleOffsets.append(CGPoint(
                x: CGFloat.random(in: -screenWidth/2...screenWidth/2),
                y: CGFloat.random(in: -screenHeight/2...screenHeight/2)
            ))
            particleOpacities.append(Double.random(in: 0.1...0.3))
        }
    }
    
    private func animateParticles() {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        
        for index in 0..<8 {
            let delay = Double(index) * 0.4
            let duration = Double.random(in: 5...10)
            let targetX = CGFloat.random(in: -screenWidth/2...screenWidth/2)
            let targetY = CGFloat.random(in: -screenHeight/2...screenHeight/2)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    if particleOffsets.indices.contains(index) {
                        particleOffsets[index] = CGPoint(x: targetX, y: targetY)
                    }
                }
            }
            
            // Opacity animation
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: duration * 0.7).repeatForever(autoreverses: true)) {
                    if particleOpacities.indices.contains(index) {
                        particleOpacities[index] = Double.random(in: 0.15...0.35)
                    }
                }
            }
        }
    }
}
