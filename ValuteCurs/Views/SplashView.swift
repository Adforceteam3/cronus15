import SwiftUI

struct SplashView: View {
    @Binding var isPresented: Bool
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.2), // #0230E1
                                Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88)) // #0230E1
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
            }
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    scale = 1.0
                    isAnimating = true
                }
            }
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isPresented = false
                }
            }
        }
    }
}
