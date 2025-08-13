import SwiftUI

struct AnimatedBackground: View {
    @State private var animate = false
    let particleCount: Int
    let colors: [Color]
    
    init(particleCount: Int = 20, colors: [Color] = [Color(red: 0.01, green: 0.19, blue: 0.88), Color.blue, Color.purple]) {
        self.particleCount = particleCount
        self.colors = colors
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.99),
                    Color(red: 0.92, green: 0.94, blue: 0.96)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating bubbles/particles
            ForEach(0..<particleCount, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                colors[index % colors.count].opacity(0.1),
                                colors[index % colors.count].opacity(0.3)
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: CGFloat.random(in: 20...80))
                    .position(
                        x: animate ? CGFloat.random(in: 0...UIScreen.main.bounds.width) : CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? CGFloat.random(in: 0...UIScreen.main.bounds.height) : CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 8...15))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...5)),
                        value: animate
                    )
                    .blur(radius: 1)
            }
            
            // Firework sparks
            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 4, height: 4)
                    .position(
                        x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 100)
                    )
                    .scaleEffect(animate ? 1.5 : 0.5)
                    .opacity(animate ? 0.3 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...3)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
        .ignoresSafeArea()
    }
}
