import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var animateGear = false
    @State private var animateButtons = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
               
                
                Spacer()
                
                // Diamond layout of buttons (2x2 rotated)
                VStack(spacing: 30) {
                    // Top button
                    settingsButton("Terms", icon: "doc.text", color: Color(red: 0.01, green: 0.19, blue: 0.88))
                    
                    // Middle row
                    HStack(spacing: 40) {
                        settingsButton("Privacy", icon: "lock.shield", color: Color.green)
                        settingsButton("Contact", icon: "envelope", color: Color.orange)
                    }
                    
                    // Bottom button
                    settingsButton("Rate App", icon: "star.fill", color: Color.red)
                }
                
                Spacer()
                
              
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.97, blue: 0.99),
                        Color(red: 0.92, green: 0.94, blue: 0.96)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateGear = true
                animateButtons = true
            }
        }
    }
    
    private func settingsButton(_ title: String, icon: String, color: Color) -> some View {
        Button(action: {
            handleButtonAction(for: title)
        }) {
            VStack(spacing: 12) {
                ZStack {
                    // Animated background glow
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .scaleEffect(animateButtons ? 1.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: animateButtons
                        )
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(animateButtons ? 360 : 0))
                        .animation(
                            Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: false).delay(Double.random(in: 0...1)),
                            value: animateButtons
                        )
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .frame(width: 80)
            }
            .frame(width: 120, height: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemGray6),
                                Color(.systemGray5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(animateButtons ? 1.0 : 0.5)
        .opacity(animateButtons ? 1.0 : 0.0)
        .rotationEffect(.degrees(animateButtons ? 0 : -90))
        .animation(
            Animation.spring(response: 0.8, dampingFraction: 0.6)
                .delay(Double.random(in: 0.1...0.6)),
            value: animateButtons
        )
        .onTapGesture {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    // MARK: - Button Actions Handler
    private func handleButtonAction(for title: String) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        switch title {
        case "Terms":
            if let url = URL(string: "https://google.com") {
                UIApplication.shared.open(url)
            }
        case "Privacy":
            if let url = URL(string: "https://google.com") {
                UIApplication.shared.open(url)
            }
        case "Contact":
            if let url = URL(string: "https://google.com") {
                UIApplication.shared.open(url)
            }
        case "Rate App":
            // Use Apple's default app review system
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        default:
            break
        }
    }
}
