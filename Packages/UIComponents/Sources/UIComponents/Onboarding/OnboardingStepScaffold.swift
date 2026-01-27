import SwiftUI

public struct OnboardingEntranceState {
    public let headerScale: CGFloat
    public let headerOpacity: Double
    public let contentOpacity: Double
    public let contentOffset: CGFloat
    
    public init(
        headerScale: CGFloat,
        headerOpacity: Double,
        contentOpacity: Double,
        contentOffset: CGFloat
    ) {
        self.headerScale = headerScale
        self.headerOpacity = headerOpacity
        self.contentOpacity = contentOpacity
        self.contentOffset = contentOffset
    }
}

/// Shared scaffold for onboarding steps with consistent entrance animations and spacing.
public struct OnboardingStepScaffold<Header: View, BodyContent: View, Footer: View>: View {
    private let isScrollable: Bool
    private let bottomPadding: CGFloat
    private let topSpacing: (GeometryProxy) -> CGFloat
    private let header: (GeometryProxy, OnboardingEntranceState) -> Header
    private let bodyContent: (GeometryProxy, OnboardingEntranceState) -> BodyContent
    private let footer: (GeometryProxy, OnboardingEntranceState) -> Footer
    private let onAppearAction: (() -> Void)?
    
    @State private var headerScale: CGFloat = 0.5
    @State private var headerOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    
    public init(
        isScrollable: Bool = false,
        bottomPadding: CGFloat = 80,
        topSpacing: @escaping (GeometryProxy) -> CGFloat,
        @ViewBuilder header: @escaping (GeometryProxy, OnboardingEntranceState) -> Header,
        @ViewBuilder bodyContent: @escaping (GeometryProxy, OnboardingEntranceState) -> BodyContent,
        @ViewBuilder footer: @escaping (GeometryProxy, OnboardingEntranceState) -> Footer,
        onAppear: (() -> Void)? = nil
    ) {
        self.isScrollable = isScrollable
        self.bottomPadding = bottomPadding
        self.topSpacing = topSpacing
        self.header = header
        self.bodyContent = bodyContent
        self.footer = footer
        self.onAppearAction = onAppear
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let state = OnboardingEntranceState(
                headerScale: headerScale,
                headerOpacity: headerOpacity,
                contentOpacity: contentOpacity,
                contentOffset: contentOffset
            )
            
            let stack = VStack(spacing: 0) {
                Spacer()
                    .frame(height: topSpacing(geometry))
                
                header(geometry, state)
                
                bodyContent(geometry, state)
                    .opacity(state.contentOpacity)
                    .offset(y: state.contentOffset)
                
                Spacer(minLength: 16)
                
                footer(geometry, state)
                    .opacity(state.contentOpacity)
                    .offset(y: state.contentOffset)
                    .padding(.bottom, bottomPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if isScrollable {
                ScrollView(showsIndicators: false) {
                    stack
                        .frame(minHeight: geometry.size.height)
                }
            } else {
                stack
            }
        }
        .onAppear {
            startAnimations()
            onAppearAction?()
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            headerScale = 1.0
            headerOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
}
