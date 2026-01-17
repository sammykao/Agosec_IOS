import SwiftUI
import UIKit

/// A modern, innovative splash screen with glassmorphic design and bold typography
public struct SplashScreenView: View {
    let logoName: String
    let appName: String
    
    // Animation states
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0.0
    @State private var logoRotation: Double = -15
    @State private var logoFloat: CGFloat = 0
    @State private var logoGlow: Double = 0.0
    
    // Text states
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 30
    @State private var textScale: CGFloat = 0.8
    
    // Background gradient animation
    @State private var gradientOffset: CGFloat = 0
    @State private var orbPositions: [CGPoint] = []
    
    // Glassmorphic elements
    @State private var glassOpacity: Double = 0.0
    
    public init(logoName: String = "agosec_logo", appName: String = "Agosec") {
        self.logoName = logoName
        self.appName = appName
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Modern glassmorphic background
                modernBackground
                    .ignoresSafeArea(.all)
                
                // Floating glass orbs for depth
                floatingGlassOrbs(in: geometry)
                
                // Main content in glassmorphic container
                VStack(spacing: 0) {
                    // Push content down
                    Spacer()
                        .frame(maxHeight: geometry.size.height * 0.2)
                    
                    // Glassmorphic logo container (responsive)
                    glassmorphicLogoContainer(in: geometry)
                        .padding(.bottom, 32)
                    
                    // Bold app name with gradient (responsive font)
                    Text(appName)
                        .font(.system(size: min(geometry.size.width * 0.15, 48), weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 0.0, green: 0.48, blue: 1.0),
                                    Color(red: 0.58, green: 0.0, blue: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(textScale)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                        .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    // Tagline with glassmorphic background (responsive)
                    Text("Your AI centered keyboard.")
                        .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                        .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                        .padding(.vertical, 12)
                        .background(
                            Color.white.opacity(0.1),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                        .padding(.horizontal, 24)
                    
                    // Flexible space
                    Spacer()
                        .frame(minHeight: 40)
                    
                    // Modern loading indicator
                    modernLoadingIndicator
                        .opacity(textOpacity)
                        .padding(.bottom, 60)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            initializeOrbs()
            startAnimations()
        }
    }
    
    // MARK: - Background
    
    private var modernBackground: some View {
        ZStack {
            // Base dark gradient with animation
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.08),
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.06, green: 0.06, blue: 0.1)
                ]),
                startPoint: UnitPoint(x: 0.5 + gradientOffset, y: 0),
                endPoint: UnitPoint(x: 0.5 - gradientOffset, y: 1)
            )
            
            // Radial accent gradients
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
        }
    }
    
    // MARK: - Floating Glass Orbs
    
    private func floatingGlassOrbs(in geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<4) { index in
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
                        x: orbPositions.indices.contains(index) ? 
                            max(-geometry.size.width * 0.3, min(geometry.size.width * 0.3, orbPositions[index].x)) : 0,
                        y: orbPositions.indices.contains(index) ? 
                            max(-geometry.size.height * 0.3, min(geometry.size.height * 0.3, orbPositions[index].y)) : 0
                    )
                    .opacity(glassOpacity * (1.0 - Double(index) * 0.15))
            }
        }
    }
    
    // MARK: - Glassmorphic Logo Container
    
    private func glassmorphicLogoContainer(in geometry: GeometryProxy) -> some View {
        let logoSize = min(geometry.size.width * 0.4, 180)
        let containerSize = logoSize * 1.15
        
        return ZStack {
            // Outer glow rings
            ForEach(0..<2) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.4 - Double(index) * 0.2),
                                Color(red: 0.58, green: 0.0, blue: 1.0).opacity(0.3 - Double(index) * 0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: containerSize + CGFloat(index) * 20, height: containerSize + CGFloat(index) * 20)
                    .scaleEffect(1.0 + CGFloat(index) * 0.1)
                    .opacity(logoGlow * (1.0 - Double(index) * 0.3))
            }
            
            // Dark container for white logo
            Circle()
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .frame(width: containerSize, height: containerSize)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.5), radius: 50, x: 0, y: 25)
                .shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 15)
                .opacity(logoOpacity)
            
            // Logo
            Group {
                if let uiImage = UIImage(named: logoName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "sparkles")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
            }
            .frame(width: logoSize, height: logoSize)
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
            .rotationEffect(.degrees(logoRotation))
            .offset(y: logoFloat)
        }
    }
    
    // MARK: - Loading Indicator
    
    private var modernLoadingIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0),
                                Color(red: 0.58, green: 0.0, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 10, height: 10)
                    .scaleEffect(loadingDotScale(for: index))
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: logoOpacity
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color.white.opacity(0.1),
            in: Capsule()
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func loadingDotScale(for index: Int) -> CGFloat {
        guard logoOpacity > 0.5 else { return 0.5 }
        return 1.0
    }
    
    // MARK: - Animations
    
    private func initializeOrbs() {
        // Initialize with safe positions that will be constrained in the view
        orbPositions = [
            CGPoint(x: -100, y: -150),
            CGPoint(x: 80, y: -120),
            CGPoint(x: -60, y: 150),
            CGPoint(x: 120, y: 140)
        ]
    }
    
    private func startAnimations() {
        // Background gradient subtle animation
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
            gradientOffset = 0.15
        }
        
        // Glass opacity fade in
        withAnimation(.easeOut(duration: 1.0)) {
            glassOpacity = 1.0
        }
        
        // Logo entrance with spring physics
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
            logoRotation = 0
        }
        
        // Logo glow pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                logoGlow = 1.0
            }
        }
        
        // Logo floating animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                logoFloat = -12
            }
        }
        
        // Text entrance with stagger
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                textOpacity = 1.0
                textOffset = 0
                textScale = 1.0
            }
        }
        
        // Animate floating orbs
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
}
