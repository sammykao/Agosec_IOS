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
    
    
    public init(logoName: String = "agosec_logo", appName: String = "Agosec") {
        self.logoName = logoName
        self.appName = appName
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                GlassmorphicBackground()
                    .ignoresSafeArea(.all)
                
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
            startAnimations()
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
    
    private func startAnimations() {
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
        
    }
}

