import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var dragOffset: CGSize = .zero
    @State private var pageAnimations: [Bool] = [false, false, false]
    
    private let pages = [
        OnboardingPage(
            icon: "dollarsign.circle.fill",
            title: "Convert Currencies",
            subtitle: "in a Snap",
            description: "Fast currency conversion with real-time rates."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Trends",
            subtitle: "with Charts", 
            description: "Explore market trends with beautiful charts."
        ),
        OnboardingPage(
            icon: "clock.arrow.circlepath",
            title: "Save History",
            subtitle: "for Later",
            description: "All your conversions saved for easy access."
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background particles
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(pageAnimations[currentPage] ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: pageAnimations[currentPage]
                    )
            }
            
            VStack(spacing: 0) {
                // Page indicators
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color(red: 0.01, green: 0.19, blue: 0.88) : Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isActive: index == currentPage,
                            pageIndex: index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                .onChange(of: currentPage) { newPage in
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                        pageAnimations[newPage] = true
                    }
                }
                
                // Continue button
                VStack(spacing: 16) {
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        HStack {
                            Text(currentPage < 2 ? "Continue" : "Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if currentPage < 2 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.01, green: 0.19, blue: 0.88),
                                    Color(red: 0.24, green: 0.35, blue: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(currentPage == 2 ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                pageAnimations[0] = true
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    let pageIndex: Int
    
    @State private var iconScale: CGFloat = 0.5
    @State private var titleOffset: CGFloat = 30
    @State private var descriptionOpacity: Double = 0
    @State private var iconRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated icon with effects
            ZStack {
                // Pulsing background
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.1),
                                Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.3)
                            ]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulseScale)
                    .animation(
                        Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: pulseScale
                    )
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 64, weight: .medium))
                    .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: iconScale)
                    .animation(.easeInOut(duration: 1.0), value: iconRotation)
            }
            
            // Title and subtitle
            VStack(spacing: 8) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: titleOffset)
                
                Text(page.subtitle)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3), value: titleOffset)
            }
            
            // Description
            Text(page.description)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
                .fixedSize(horizontal: false, vertical: true) // Позволяет тексту переноситься
                .opacity(descriptionOpacity)
                .animation(.easeInOut(duration: 0.8).delay(0.5), value: descriptionOpacity)
            
            Spacer()
        }
        .onChange(of: isActive) { active in
            if active {
                startAnimations()
            }
        }
        .onAppear {
            if isActive {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            iconScale = 1.0
            titleOffset = 0
            descriptionOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
            iconRotation = 360
            pulseScale = 1.2
        }
        
        // Reset rotation for next time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            iconRotation = 0
        }
    }
}
